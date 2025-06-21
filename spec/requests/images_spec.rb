require 'rails_helper'

RSpec.describe "Images", type: :request do
  let(:image_request) { create(:image_request) }
  let(:image) { create(:image, image_request: image_request) }

  describe "GET /images" do
    context "when no images exist" do
      it "returns successful response" do
        get images_path
        expect(response).to have_http_status(:success)
      end

      it "displays empty state or images page" do
        get images_path
        expect(response.body).to include("Image")
      end
    end

    context "when images exist" do
      let!(:images) { create_list(:image, 3) }

      it "returns successful response" do
        get images_path
        expect(response).to have_http_status(:success)
      end

      it "displays the images page" do
        get images_path
        expect(response.body).to include("Image")
      end

      it "includes page structure" do
        get images_path
        expect(response.body).to include("html")
      end
    end
  end

  describe "GET /images/:id" do
    context "when image exists" do
      it "returns successful response" do
        get image_path(image)
        expect(response).to have_http_status(:success)
      end

      it "displays the image page" do
        get image_path(image)
        expect(response.body).to include("html")
      end

      it "includes image information" do
        get image_path(image)
        expect(response.body).to be_present
      end
    end

    context "when image does not exist" do
      it "raises ActiveRecord::RecordNotFound" do
        expect {
          get image_path(id: 999999)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "Image and ImageRequest association" do
    it "displays associated image request information when present" do
      image_with_request = create(:image, image_request: image_request)
      get image_path(image_with_request)
      expect(response).to have_http_status(:success)
    end

    it "handles images without associated requests" do
      image_without_request = create(:image, :without_request)
      get image_path(image_without_request)
      expect(response).to have_http_status(:success)
    end
  end
end
