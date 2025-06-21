require 'rails_helper'
require 'webmock/rspec'

RSpec.describe GenerateVariationJob, type: :job do
  include ActiveJob::TestHelper

  let(:variation_request) { create(:variation_request) }
  let(:image) { variation_request.images.first }

  # Mock OpenAI API response for image edits
  let(:dalle2_edit_response) do
    {
      "data" => [
        {
          "url" => "https://example.com/edited-image.png"
        }
      ]
    }
  end

  let(:generated_image_data) { "fake generated image data" }

  before do
    # Stub image download for preparation
    allow_any_instance_of(GenerateVariationJob).to receive(:prepare_image_for_editing) do
      temp_file = Tempfile.new([ 'test_image', '.png' ])
      temp_file.binmode
      temp_file.write("test image data")
      temp_file.rewind
      temp_file
    end

    # Stub mask creation
    allow_any_instance_of(GenerateVariationJob).to receive(:create_full_image_mask) do
      temp_mask = Tempfile.new([ 'test_mask', '.png' ])
      temp_mask.binmode
      temp_mask.write("white mask data")
      temp_mask.rewind
      temp_mask
    end

    # Stub the OpenAI image edits API call
    stub_request(:post, "https://api.openai.com/v1/images/edits")
      .to_return(
        status: 200,
        body: dalle2_edit_response.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    # Stub the image download
    stub_request(:get, "https://example.com/edited-image.png")
      .to_return(
        status: 200,
        body: generated_image_data,
        headers: { 'Content-Type' => 'image/png' }
      )
  end

  describe '#perform' do
    context 'when variation request has no existing variation' do
      it 'generates a new variation successfully' do
        expect {
          described_class.perform_now(variation_request)
        }.to change { Variation.count }.by(1)

        variation_request.reload
        expect(variation_request.variation).to be_present
        expect(variation_request.variation.image).to eq(image)
        expect(variation_request.variation.file).to be_attached
      end

      it 'calls DALL-E 2 image edits API' do
        described_class.perform_now(variation_request)

        expect(WebMock).to have_requested(:post, "https://api.openai.com/v1/images/edits")
      end

      it 'downloads and attaches the generated image' do
        described_class.perform_now(variation_request)

        variation = variation_request.reload.variation
        expect(variation.file).to be_attached
        expect(variation.file.filename.to_s).to match(/variation_\d+\.png/)
        expect(variation.file.content_type).to eq("image/png")

        expect(WebMock).to have_requested(:get, "https://example.com/edited-image.png")
      end

      it 'logs the process' do
        allow(Rails.logger).to receive(:info) # Allow other log messages
        expect(Rails.logger).to receive(:info).with(/Starting variation generation/)
        expect(Rails.logger).to receive(:info).with(/Successfully generated variation/)

        described_class.perform_now(variation_request)
      end
    end

    context 'when variation request already has a variation' do
      let(:existing_variation) { create(:variation, image: image) }

      before do
        variation_request.update!(variation: existing_variation)
      end

      it 'does not generate a new variation' do
        expect {
          described_class.perform_now(variation_request)
        }.not_to change { Variation.count }

        expect(WebMock).not_to have_requested(:post, "https://api.openai.com/v1/images/edits")
      end
    end

    context 'when variation request has no source images' do
      let(:variation_request_without_images) { create(:variation_request) }

      before do
        variation_request_without_images.images.clear
      end

      it 'logs an error and returns early' do
        expect(Rails.logger).to receive(:error).with(/No source images with attached files/)

        expect {
          described_class.perform_now(variation_request_without_images)
        }.not_to change { Variation.count }
      end
    end

    context 'when OpenAI image edits API fails' do
      before do
        stub_request(:post, "https://api.openai.com/v1/images/edits")
          .to_return(status: 500, body: "Internal Server Error")
      end

      it 'logs an error and raises an exception' do
        allow(Rails.logger).to receive(:info)
        allow(Rails.logger).to receive(:error)
        expect(Rails.logger).to receive(:error).with(/Failed to generate variation/)

        expect {
          described_class.perform_now(variation_request)
        }.to raise_error(StandardError)
      end
    end

    context 'when DALL-E 2 edits API returns no image URL' do
      let(:empty_dalle2_response) do
        {
          "data" => [ {} ]
        }
      end

      before do
        stub_request(:post, "https://api.openai.com/v1/images/edits")
          .to_return(
            status: 200,
            body: empty_dalle2_response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'logs an error but does not raise an exception' do
        allow(Rails.logger).to receive(:info)
        allow(Rails.logger).to receive(:error)
        expect(Rails.logger).to receive(:error).with(/No image URL in OpenAI response/)

        expect {
          described_class.perform_now(variation_request)
        }.not_to raise_error
      end
    end

    context 'when image download fails' do
      before do
        stub_request(:get, "https://example.com/edited-image.png")
          .to_return(status: 404, body: "Not Found")
      end

      it 'logs an error and raises an exception' do
        allow(Rails.logger).to receive(:info)
        allow(Rails.logger).to receive(:error)
        expect(Rails.logger).to receive(:error).with(/Failed to generate variation/)

        expect {
          described_class.perform_now(variation_request)
        }.to raise_error(StandardError)
      end
    end
  end

  describe '#build_edit_prompt' do
    let(:job) { described_class.new }

    it 'includes the prompt and style preservation instructions' do
      prompt = job.send(:build_edit_prompt, "Show character running")
      expect(prompt).to include("Show character running")
    end

    it 'adds conservative preservation instructions' do
      prompt = job.send(:build_edit_prompt, "Make the character smile")
      expect(prompt).to include("Make the character smile")
      expect(prompt).to include("maintaining the exact same artistic style and technique")
      expect(prompt).to include("make only the minimal changes necessary")
    end
  end

  describe '#prepare_image_for_editing' do
    let(:job) { described_class.new }

    it 'creates a temporary file with image data' do
      # Don't stub prepare_image_for_editing for this test
      allow_any_instance_of(GenerateVariationJob).to receive(:prepare_image_for_editing).and_call_original

      # Mock the image download
      allow(image.file).to receive(:download).and_return("test image data")

      result = job.send(:prepare_image_for_editing, image)

      expect(result).to be_a(Tempfile)
      expect(result.path).to end_with('.png')

      # Read the file content to verify it was written correctly
      result.rewind
      content = result.read
      expect(content).to eq("test image data")

      # Clean up
      result.close!
    end
  end

  describe '#create_full_image_mask' do
    let(:job) { described_class.new }

    it 'creates a white mask covering the entire image' do
      # Don't stub create_full_image_mask for this test
      allow_any_instance_of(GenerateVariationJob).to receive(:create_full_image_mask).and_call_original

      # Create a mock image file
      image_file = Tempfile.new([ 'test_image', '.png' ])
      image_file.binmode

      # Create a simple 100x100 white PNG for testing
      require 'vips'
      test_image = Vips::Image.black(100, 100, bands: 3) + [ 255, 255, 255 ]
      image_file.write(test_image.write_to_buffer(".png"))
      image_file.rewind

      result = job.send(:create_full_image_mask, image_file)

      expect(result).to be_a(Tempfile)
      expect(result.path).to end_with('.png')

      # Verify the mask is the correct size and white
      result.rewind
      mask_content = result.read
      expect(mask_content).not_to be_empty

      # Clean up
      result.close!
      image_file.close!
    end
  end
end
