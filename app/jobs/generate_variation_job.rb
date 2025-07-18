class GenerateVariationJob < ApplicationJob
  require "open-uri"
  require "tempfile"
  require "vips"
  SIZE_FOR_EDITING = [512, 512].freeze

  queue_as :default

  def perform(variation_request)
    @variation_request = variation_request

    Rails.logger.info "Starting variation generation for VariationRequest ##{@variation_request.id}"

    # Return if variation already exists
    return if @variation_request.variation.present?

    # Ensure we have at least one source image with attached file
    source_images = @variation_request.images.joins(:file_attachment)
    if source_images.empty?
      Rails.logger.error "No source images with attached files for VariationRequest ##{@variation_request.id}"
      return
    end

    begin
      # Use the first source image for editing with DALL-E 2
      source_image = source_images.first
      edit_prompt = build_edit_prompt(@variation_request.prompt)

      response = generate_variation_with_ai(source_image, edit_prompt)

      if response.dig("data", -1, "b64_json").present?
        image_data = response.dig("data", -1, "b64_json")

        create_variation_from_data(@variation_request, image_data, edit_prompt)
        Rails.logger.info "Successfully generated variation for VariationRequest ##{@variation_request.id}"
      else
        Rails.logger.error "No image data in OpenAI response for VariationRequest ##{@variation_request.id}"
      end

    rescue => e
      Rails.logger.error "Failed to generate variation for VariationRequest ##{@variation_request.id}: #{e.message}"
      raise e
    end
  end

  private

  def build_edit_prompt(user_prompt)
    # Make the prompt more conservative to preserve the original design
    conservative_prompt = build_conservative_prompt(user_prompt)
    conservative_prompt
  end

  def build_conservative_prompt(user_prompt)
    # Add strong design preservation instructions
    preservation_instructions = [
      "keeping the original design completely intact",
      "maintaining the exact same artistic style and technique",
      "without changing any core design elements",
      "make only the minimal changes necessary"
    ].join(", ")

    "#{user_prompt}, #{preservation_instructions}"
  end

  def generate_variation_with_ai(source_image, prompt)
    client = OpenAI::Client.new

    # Convert image to the required format
    image_file = prepare_image_for_editing(source_image)

    # Create mask - use custom mask if provided, otherwise full image mask
    mask_file = if @variation_request.mask_data.present?
      create_custom_mask_from_data(@variation_request)
    else
      create_full_image_mask(image_file)
    end

    begin
      # Use edits endpoint with mask
      response = client.images.edit(
        parameters: {
          image: image_file,
          mask: mask_file,
          prompt: prompt,
          n: 1,
          size: "auto",
          background: "transparent", # Use transparent background for better results
          model: "gpt-image-1"
        }
      )
      response
    ensure
      # Clean up temporary files
      image_file.close! if image_file.respond_to?(:close!)
      mask_file.close! if mask_file.respond_to?(:close!)
    end
  end

  def prepare_image_for_editing(image)
    # Download and prepare the image as a File object for the API
    small_image = image.file.variant(
      resize_to_limit: SIZE_FOR_EDITING,
      format: :png,
      saver: { quality: 90 }
    ).processed

    processed_data = small_image.download

    # Preprocess image for better results with DALL-E 2
    # Create a temporary file with proper extension
    temp_file = Tempfile.new([ "source_image", ".png" ])
    temp_file.binmode
    temp_file.write(processed_data)
    temp_file.rewind

    temp_file
  end

  def create_variation_from_data(variation_request, image_data, edit_prompt)
    # Create new variation
    variation = Variation.create!(
      image: variation_request.images.first # Link to the primary source image
    )

    # Attach the downloaded image
    variation.file.attach(
      io: StringIO.new(Base64.decode64(image_data)),
      filename: "variation_#{variation.id}.png",
      content_type: "image/png"
    )

    # Link to the variation request
    variation_request.update!(variation: variation)

    Rails.logger.info "Variation attached to Variation ##{variation.id} and linked to VariationRequest ##{variation_request.id}"

    variation
  end

  def create_full_image_mask(image_file)
    # Create a white mask that covers the entire image (allows editing everywhere)
    # Read the original image to get dimensions
    image_file.rewind
    image = Vips::Image.new_from_buffer(image_file.read, "")
    image_file.rewind

    width = image.width
    height = image.height

    Rails.logger.info "Creating full mask with dimensions: #{width}x#{height}"

    # Create a completely white mask (indicates the entire image can be edited)
    # Use uchar format to match what OpenAI expects
    mask = Vips::Image.black(width, height, bands: 1).cast(:uchar) + 255

    # Convert to PNG format
    mask_data = mask.write_to_buffer(".png")

    # Save to temporary file
    temp_mask = Tempfile.new([ "full_mask", ".png" ])
    temp_mask.binmode
    temp_mask.write(mask_data)
    temp_mask.rewind

    temp_mask
  end

  def create_custom_mask_from_data(variation_request)
    variation_request.attach_mask_data
    
    small_image = variation_request.mask.variant(
      resize_to_limit: SIZE_FOR_EDITING,
      format: :png,
      saver: { quality: 90 }
    ).processed

    processed_data = small_image.download

    # Preprocess image for better results with DALL-E 2
    # Create a temporary file with proper extension
    temp_file = Tempfile.new([ "mask_image", ".png" ])
    temp_file.binmode
    temp_file.write(processed_data)
    temp_file.rewind

    temp_file
  end
end