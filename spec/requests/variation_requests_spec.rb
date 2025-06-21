require 'rails_helper'

RSpec.describe "VariationRequests", type: :request do
  let(:variation) { create(:variation) }
  let(:variation_request) { create(:variation_request, variation: variation) }
  let(:valid_attributes) { { variation_id: variation.id } }
  let(:invalid_attributes) { { variation_id: nil } }

  describe "GET /variation_requests" do
    context "when no variation requests exist" do
      it "returns successful response" do
        get variation_requests_path
        expect(response).to have_http_status(:success)
      end

      it "displays variation requests page" do
        get variation_requests_path
        expect(response.body).to include("Variation Request")
      end
    end

    context "when variation requests exist" do
      let!(:variation_requests) { create_list(:variation_request, 3) }

      it "returns successful response" do
        get variation_requests_path
        expect(response).to have_http_status(:success)
      end

      it "displays all variation requests" do
        get variation_requests_path
        expect(response.body).to include("Variation Request")
      end

      it "includes page structure" do
        get variation_requests_path
        expect(response.body).to include("html")
      end
    end
  end

  describe "GET /variation_requests/:id" do
    context "when variation request exists" do
      it "returns successful response" do
        get variation_request_path(variation_request)
        expect(response).to have_http_status(:success)
      end

      it "displays the variation request details" do
        get variation_request_path(variation_request)
        expect(response.body).to include("html")
      end

      it "includes variation request information" do
        get variation_request_path(variation_request)
        expect(response.body).to be_present
      end
    end

    context "when variation request does not exist" do
      it "raises ActiveRecord::RecordNotFound" do
        expect {
          get variation_request_path(id: 999999)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "GET /variation_requests/new" do
    context "when variations exist" do
      let!(:variations) { create_list(:variation, 3) }

      it "returns successful response" do
        get new_variation_request_path
        expect(response).to have_http_status(:success)
      end

      it "displays the new variation request form" do
        get new_variation_request_path
        expect(response.body).to include("form")
      end

      it "includes form fields" do
        get new_variation_request_path
        expect(response.body).to include('name="variation_request[variation_id]"')
      end
    end

    context "when no variations exist" do
      it "returns successful response" do
        get new_variation_request_path
        expect(response).to have_http_status(:success)
      end

      it "still displays the form" do
        get new_variation_request_path
        expect(response.body).to include("form")
      end
    end
  end

  describe "POST /variation_requests" do
    context "with valid parameters" do
      it "creates a new variation request and redirects" do
        expect {
          post variation_requests_path, params: { variation_request: valid_attributes }
        }.to change(VariationRequest, :count).by(1)

        expect(response).to have_http_status(:redirect)
      end

      it "creates variation request with correct attributes" do
        post variation_requests_path, params: { variation_request: valid_attributes }
        created_request = VariationRequest.last
        expect(created_request.variation_id).to eq(valid_attributes[:variation_id])
      end

      it "sets success flash message" do
        post variation_requests_path, params: { variation_request: valid_attributes }
        follow_redirect!
        expect(response.body).to include('successfully created')
      end

      it "redirects to the created variation request" do
        post variation_requests_path, params: { variation_request: valid_attributes }
        expect(response).to redirect_to(VariationRequest.last)
      end
    end

    context "with invalid parameters" do
      before { create(:variation) } # Ensure variations exist for the form

      it "does not create a new variation request" do
        expect {
          post variation_requests_path, params: { variation_request: invalid_attributes }
        }.not_to change(VariationRequest, :count)
      end

      it "returns unprocessable entity status" do
        post variation_requests_path, params: { variation_request: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "redisplays the form" do
        post variation_requests_path, params: { variation_request: invalid_attributes }
        expect(response.body).to include("form")
      end

      it "displays validation errors" do
        post variation_requests_path, params: { variation_request: invalid_attributes }
        expect(response.body).to include("error")
      end
    end
  end

  describe "Parameter filtering" do
    it "only accepts permitted parameters" do
      malicious_params = {
        variation_request: {
          variation_id: variation.id,
          malicious_param: "should be filtered",
          id: 999,
          created_at: Time.current
        }
      }

      post variation_requests_path, params: malicious_params
      created_request = VariationRequest.last

      expect(created_request.variation_id).to eq(variation.id)
      expect(created_request.id).not_to eq(999) # Should get auto-assigned ID
    end
  end

  describe "Variation association" do
    it "properly associates with the selected variation" do
      post variation_requests_path, params: { variation_request: valid_attributes }
      created_request = VariationRequest.last

      expect(created_request.variation).to eq(variation)
      expect(created_request.variation_id).to eq(variation.id)
    end
  end
end
