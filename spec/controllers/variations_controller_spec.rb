require 'rails_helper'

RSpec.describe VariationsController, type: :controller do
  let(:image) { create(:image) }
  let(:variation) { create(:variation, image: image) }

  describe "GET #new" do
    it "returns a success response" do
      get :new
      expect(response).to be_successful
    end

    it "assigns a new variation" do
      get :new
      expect(assigns(:variation)).to be_a_new(Variation)
    end

    it "assigns all images" do
      image # create the image
      get :new
      expect(assigns(:images)).to include(image)
    end

    it "pre-selects image when image_id param is provided" do
      get :new, params: { image_id: image.id }
      expect(assigns(:variation).image_id).to eq(image.id)
    end
  end

  describe "POST #create" do
    let(:file) { fixture_file_upload('spec/fixtures/test_image.png', 'image/png') }

    context "with valid parameters" do
      let(:valid_attributes) {
        {
          image_id: image.id,
          file: file
        }
      }

      it "creates a new Variation" do
        expect {
          post :create, params: { variation: valid_attributes }
        }.to change(Variation, :count).by(1)
      end

      it "redirects to the created variation" do
        post :create, params: { variation: valid_attributes }
        expect(response).to redirect_to(Variation.last)
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) {
        {
          image_id: nil,
          file: nil
        }
      }

      it "does not create a new Variation" do
        expect {
          post :create, params: { variation: invalid_attributes }
        }.to_not change(Variation, :count)
      end

      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { variation: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
