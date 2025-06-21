require 'rails_helper'

RSpec.describe "Dashboard", type: :request do
  describe "GET /" do
    context "when database is empty" do
      it "returns successful response" do
        get root_path
        expect(response).to have_http_status(:success)
      end

      it "displays zero counts in the response body" do
        get root_path
        expect(response.body).to include("0") # Total Styles count
        expect(response.body).to include("No images yet")
      end

      it "displays empty state message" do
        get root_path
        expect(response.body).to include("No images yet")
        expect(response.body).to include("Get started by creating your first AI-generated image")
      end

      it "includes dashboard navigation and structure" do
        get root_path
        expect(response.body).to include("Dashboard")
        expect(response.body).to include("Asset Generator")
        expect(response.body).to include("Quick Actions")
      end
    end

    context "when database has data" do
      let!(:styles) { create_list(:style, 3) }
      let!(:images) { create_list(:image, 5) }
      let!(:variations) { create_list(:variation, 2) }

      it "returns successful response" do
        get root_path
        expect(response).to have_http_status(:success)
      end

      it "displays correct counts in the response body" do
        get root_path
        expect(response.body).to include("3") # Styles count
        expect(response.body).to include("5") # Images count
        expect(response.body).to include("2") # Variations count
      end

      it "includes styles and images data" do
        get root_path
        expect(response.body).to include("Total Styles")
        expect(response.body).to include("Generated Images")
        expect(response.body).to include("Total Variations")
      end

      it "displays recent images section when images exist" do
        get root_path
        expect(response.body).to include("Recent Images")
        expect(response.body).not_to include("No images yet")
      end
    end
  end

  describe "GET /dashboard" do
    it "returns successful response" do
      get dashboard_path
      expect(response).to have_http_status(:success)
    end

    it "displays the same content as root path" do
      get dashboard_path
      expect(response.body).to include("Dashboard")
      expect(response.body).to include("Asset Generator")
    end
  end
end
