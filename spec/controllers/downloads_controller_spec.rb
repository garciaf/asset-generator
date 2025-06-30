require 'rails_helper'

RSpec.describe DownloadsController, type: :controller do
  describe "GET #show" do
    let(:image) { create(:image, :with_file) }

    context "when image exists and has files" do
      it "generates and sends a zip file" do
        get :show, params: { id: image.id }
        
        expect(response.status).to eq(200)
        expect(response.headers['Content-Type']).to eq('application/zip')
        expect(response.headers['Content-Disposition']).to include('attachment')
      end
    end

    context "when image has no files" do
      let(:image) { create(:image) }

      it "redirects with an alert" do
        get :show, params: { id: image.id }
        
        expect(response).to redirect_to(image)
        expect(flash[:alert]).to eq("No files available for download.")
      end
    end

    context "when image does not exist" do
      it "redirects to images index with an alert" do
        get :show, params: { id: 999999 }
        
        expect(response).to redirect_to(images_path)
        expect(flash[:alert]).to eq("Image not found.")
      end
    end
  end
end
