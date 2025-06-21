require 'rails_helper'

RSpec.describe "Variations", type: :request do
  let(:image) { create(:image) }
  let(:variation) { create(:variation, image: image) }

  describe "GET /variations" do
    context "when no variations exist" do
      it "returns successful response" do
        get variations_path
        expect(response).to have_http_status(:success)
      end

      it "displays variations page" do
        get variations_path
        expect(response.body).to include("Variation")
      end
    end

    context "when variations exist" do
      let!(:variations) { create_list(:variation, 3) }

      it "returns successful response" do
        get variations_path
        expect(response).to have_http_status(:success)
      end

      it "displays the variations page" do
        get variations_path
        expect(response.body).to include("Variation")
      end

      it "includes page structure" do
        get variations_path
        expect(response.body).to include("html")
      end
    end
  end

  describe "GET /variations/:id" do
    context "when variation exists" do
      it "returns successful response" do
        get variation_path(variation)
        expect(response).to have_http_status(:success)
      end

      it "displays the variation page" do
        get variation_path(variation)
        expect(response.body).to include("html")
      end

      it "includes variation information" do
        get variation_path(variation)
        expect(response.body).to be_present
      end
    end

    context "when variation does not exist" do
      it "raises ActiveRecord::RecordNotFound" do
        expect {
          get variation_path(id: 999999)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "Variation and Image association" do
    it "displays associated parent image information" do
      get variation_path(variation)
      expect(response).to have_http_status(:success)
      expect(response.body).to be_present
    end

    it "handles variations with different parent images" do
      different_image = create(:image)
      variation_with_different_parent = create(:variation, image: different_image)

      get variation_path(variation_with_different_parent)
      expect(response).to have_http_status(:success)
    end
  end
end
