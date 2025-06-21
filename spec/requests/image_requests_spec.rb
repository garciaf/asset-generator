require 'rails_helper'

RSpec.describe "ImageRequests", type: :request do
  let(:style) { create(:style) }
  let(:image_request) { create(:image_request, style: style) }
  let(:valid_attributes) { { prompt: "Generate a beautiful sunset", style_id: style.id } }
  let(:invalid_attributes) { { prompt: "", style_id: nil } }

  describe "GET /image_requests" do
    context "when no image requests exist" do
      it "returns successful response" do
        get image_requests_path
        expect(response).to have_http_status(:success)
      end

      it "displays empty state message" do
        get image_requests_path
        expect(response.body).to include("Image Request")
      end
    end

    context "when image requests exist" do
      let!(:image_requests) { create_list(:image_request, 3, prompt: "Test prompt") }

      it "returns successful response" do
        get image_requests_path
        expect(response).to have_http_status(:success)
      end

      it "displays all image requests" do
        get image_requests_path
        image_requests.each do |request|
          expect(response.body).to include(request.prompt)
        end
      end

      it "includes page header" do
        get image_requests_path
        expect(response.body).to include("Image Request") # Could be singular or plural
      end
    end
  end

  describe "GET /image_requests/:id" do
    context "when image request exists" do
      it "returns successful response" do
        get image_request_path(image_request)
        expect(response).to have_http_status(:success)
      end

      it "displays the image request details" do
        get image_request_path(image_request)
        expect(response.body).to include(image_request.prompt)
      end

      it "displays associated style information" do
        get image_request_path(image_request)
        expect(response.body).to include(image_request.style.title)
      end
    end

    context "when image request does not exist" do
      it "raises ActiveRecord::RecordNotFound" do
        expect {
          get image_request_path(id: 999999)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "GET /image_requests/new" do
    context "when styles exist" do
      let!(:styles) { create_list(:style, 3) }

      it "returns successful response" do
        get new_image_request_path
        expect(response).to have_http_status(:success)
      end

      it "displays the new image request form" do
        get new_image_request_path
        expect(response.body).to include("form")
        expect(response.body).to include("prompt")
      end

      it "includes style selection options" do
        get new_image_request_path
        styles.each do |style|
          expect(response.body).to include(style.title)
        end
      end

      it "includes form fields" do
        get new_image_request_path
        expect(response.body).to include('name="image_request[prompt]"')
        expect(response.body).to include('name="image_request[style_id]"')
      end
    end

    context "when no styles exist" do
      it "returns successful response" do
        get new_image_request_path
        expect(response).to have_http_status(:success)
      end

      it "still displays the form" do
        get new_image_request_path
        expect(response.body).to include("form")
        expect(response.body).to include("prompt")
      end
    end
  end

  describe "POST /image_requests" do
    context "with valid parameters" do
      it "creates a new image request and redirects" do
        expect {
          post image_requests_path, params: { image_request: valid_attributes }
        }.to change(ImageRequest, :count).by(1)

        expect(response).to have_http_status(:redirect)
      end

      it "creates image request with correct attributes" do
        post image_requests_path, params: { image_request: valid_attributes }
        created_request = ImageRequest.last
        expect(created_request.prompt).to eq(valid_attributes[:prompt])
        expect(created_request.style_id).to eq(valid_attributes[:style_id])
      end

      it "sets success flash message" do
        post image_requests_path, params: { image_request: valid_attributes }
        follow_redirect!
        expect(response.body).to include('successfully created')
      end

      it "redirects to the created image request" do
        post image_requests_path, params: { image_request: valid_attributes }
        expect(response).to redirect_to(ImageRequest.last)
      end
    end

    context "with invalid parameters" do
      before { create(:style) } # Ensure styles exist for the form

      it "does not create a new image request" do
        expect {
          post image_requests_path, params: { image_request: invalid_attributes }
        }.not_to change(ImageRequest, :count)
      end

      it "returns unprocessable entity status" do
        post image_requests_path, params: { image_request: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "redisplays the form" do
        post image_requests_path, params: { image_request: invalid_attributes }
        expect(response.body).to include("form")
        expect(response.body).to include("prompt")
      end

      it "displays validation errors" do
        post image_requests_path, params: { image_request: invalid_attributes }
        expect(response.body).to include("error")
      end
    end
  end

  describe "Parameter filtering" do
    it "only accepts permitted parameters" do
      malicious_params = {
        image_request: {
          prompt: "Test prompt",
          style_id: style.id,
          malicious_param: "should be filtered",
          id: 999,
          created_at: Time.current
        }
      }

      post image_requests_path, params: malicious_params
      created_request = ImageRequest.last

      expect(created_request.prompt).to eq("Test prompt")
      expect(created_request.style_id).to eq(style.id)
      expect(created_request.id).not_to eq(999) # Should get auto-assigned ID
    end
  end

  describe "Style association" do
    it "properly associates with the selected style" do
      post image_requests_path, params: { image_request: valid_attributes }
      created_request = ImageRequest.last

      expect(created_request.style).to eq(style)
      expect(created_request.style.title).to eq(style.title)
    end
  end
end
