class GenerateImageJob < ApplicationJob
  require "open-uri"

  queue_as :default

  def perform(image_request)
    @image_request = image_request

    begin
      # Combine style prompt with user prompt
      combined_prompt = build_combined_prompt(@image_request)

      # Generate image via OpenAI
      openai_response = generate_image_with_openai(combined_prompt)

      # Download and attach image
      download_and_attach_image(openai_response)

      Rails.logger.info "Successfully generated image for ImageRequest ##{@image_request.id}"
    rescue => e
      Rails.logger.error "Failed to generate image for ImageRequest ##{@image_request.id}: #{e.message}"
      raise e
    end
  end

  private

  def build_combined_prompt(image_request)
    style_prompt = image_request.style.prompt.presence || ""
    user_prompt = image_request.prompt

    if style_prompt.present?
      "#{user_prompt}. Style: #{style_prompt}"
    else
      user_prompt
    end
  end

  def generate_image_with_openai(prompt)
    client = OpenAI::Client.new

    response = client.images.generate(
      parameters: {
        model: "gpt-image-1",
        prompt: prompt,
        size: "1024x1024",
        quality: "auto"
      }
    )

    response
  end

  def download_and_attach_image(openai_response)
    image_data = openai_response.dig("data", 0, "b64_json")
    revised_prompt = openai_response.dig("data", 0, "revised_prompt")

    # Create Image record
    image = Image.create!(
      title: generate_image_title,
      description: revised_prompt || @image_request.prompt
    )
    Rails.logger.info "Created Image ##{image.id} for ImageRequest ##{@image_request.id}"
    Rails.logger.info "Image data size: #{image_data.size} bytes"
    # Download and attach the image file
    downloaded_image = StringIO.new(Base64.decode64(image_data))

    # Generate filename with timestamp
    filename = "generated_image_#{Time.current.to_i}.png"

    # Attach file to the image record
    image.file.attach(
      io: downloaded_image,
      filename: filename,
      content_type: "image/png"
    )

    # Update the image request to reference the created image
    @image_request.update!(image: image)

    Rails.logger.info "Image attached to Image ##{image.id} and linked to ImageRequest ##{@image_request.id}"
  end

  def generate_image_title
    base_title = @image_request.prompt.truncate(50, omission: "...")
    "#{base_title} - #{@image_request.style.title}"
  end
end
