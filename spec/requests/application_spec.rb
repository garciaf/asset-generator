require 'rails_helper'

RSpec.describe "Application Routes and Navigation", type: :request do
  describe "Root route" do
    it "routes to dashboard#index" do
      expect(get: "/").to route_to("dashboard#index")
    end

    it "returns successful response" do
      get "/"
      expect(response).to have_http_status(:success)
    end
  end

  describe "Dashboard routes" do
    it "routes /dashboard to dashboard#index" do
      expect(get: "/dashboard").to route_to("dashboard#index")
    end
  end

  describe "Styles routes" do
    it "routes GET /styles to styles#index" do
      expect(get: "/styles").to route_to("styles#index")
    end

    it "routes GET /styles/new to styles#new" do
      expect(get: "/styles/new").to route_to("styles#new")
    end

    it "routes POST /styles to styles#create" do
      expect(post: "/styles").to route_to("styles#create")
    end

    it "routes GET /styles/:id to styles#show" do
      expect(get: "/styles/1").to route_to("styles#show", id: "1")
    end

    it "routes GET /styles/:id/edit to styles#edit" do
      expect(get: "/styles/1/edit").to route_to("styles#edit", id: "1")
    end

    it "routes PATCH /styles/:id to styles#update" do
      expect(patch: "/styles/1").to route_to("styles#update", id: "1")
    end

    it "routes DELETE /styles/:id to styles#destroy" do
      expect(delete: "/styles/1").to route_to("styles#destroy", id: "1")
    end
  end

  describe "Image requests routes" do
    it "routes GET /image_requests to image_requests#index" do
      expect(get: "/image_requests").to route_to("image_requests#index")
    end

    it "routes GET /image_requests/new to image_requests#new" do
      expect(get: "/image_requests/new").to route_to("image_requests#new")
    end

    it "routes POST /image_requests to image_requests#create" do
      expect(post: "/image_requests").to route_to("image_requests#create")
    end

    it "routes GET /image_requests/:id to image_requests#show" do
      expect(get: "/image_requests/1").to route_to("image_requests#show", id: "1")
    end

    it "does not route to edit actions" do
      expect(get: "/image_requests/1/edit").not_to be_routable
    end

    it "does not route to update actions" do
      expect(patch: "/image_requests/1").not_to be_routable
    end

    it "does not route to destroy actions" do
      expect(delete: "/image_requests/1").not_to be_routable
    end
  end

  describe "Images routes" do
    it "routes GET /images to images#index" do
      expect(get: "/images").to route_to("images#index")
    end

    it "routes GET /images/:id to images#show" do
      expect(get: "/images/1").to route_to("images#show", id: "1")
    end

    it "does not route to create actions" do
      expect(post: "/images").not_to be_routable
    end

    it "does not route to new actions" do
      expect(get: "/images/new").not_to be_routable
    end
  end

  describe "Variations routes" do
    it "routes GET /variations to variations#index" do
      expect(get: "/variations").to route_to("variations#index")
    end

    it "routes GET /variations/:id to variations#show" do
      expect(get: "/variations/1").to route_to("variations#show", id: "1")
    end

    it "does not route to create actions" do
      expect(post: "/variations").not_to be_routable
    end
  end

  describe "Variation requests routes" do
    it "routes GET /variation_requests to variation_requests#index" do
      expect(get: "/variation_requests").to route_to("variation_requests#index")
    end

    it "routes GET /variation_requests/new to variation_requests#new" do
      expect(get: "/variation_requests/new").to route_to("variation_requests#new")
    end

    it "routes POST /variation_requests to variation_requests#create" do
      expect(post: "/variation_requests").to route_to("variation_requests#create")
    end

    it "routes GET /variation_requests/:id to variation_requests#show" do
      expect(get: "/variation_requests/1").to route_to("variation_requests#show", id: "1")
    end
  end

  describe "Navigation structure" do
    let!(:style) { create(:style) }

    it "includes consistent navigation across pages" do
      pages = [
        "/",
        "/dashboard",
        "/styles",
        "/images",
        "/variations"
      ]

      pages.each do |page|
        get page
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Asset Generator")
        expect(response.body).to include("Dashboard")
        expect(response.body).to include("Styles")
        expect(response.body).to include("Images")
        expect(response.body).to include("Variations")
      end
    end

    it "includes proper HTML structure on all pages" do
      pages = [
        "/",
        "/styles",
        "/styles/new"
      ]

      pages.each do |page|
        get page
        expect(response).to have_http_status(:success)
        expect(response.body).to include("<!DOCTYPE html>")
        expect(response.body).to include("<html")
        expect(response.body).to include("<head>")
        expect(response.body).to include("<body")
        expect(response.body).to include("</html>")
      end
    end
  end

  describe "Error handling" do
    it "returns 404 for non-existent routes" do
      expect {
        get "/non_existent_route"
      }.to raise_error(ActionController::RoutingError)
    end

    it "handles missing records gracefully" do
      expect {
        get "/styles/999999"
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "Content Security Policy" do
    it "includes CSP headers or meta tags" do
      get "/"
      expect(response.body).to include("csp-nonce")
      expect(response.headers).to have_key("Content-Security-Policy")
    end
  end

  describe "CSRF Protection" do
    it "includes CSRF meta tags" do
      get "/"
      expect(response.body).to include("csrf-token")
    end
  end
end
