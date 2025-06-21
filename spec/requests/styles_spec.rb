require 'rails_helper'

RSpec.describe "Styles", type: :request do
  let(:style) { create(:style) }
  let(:valid_attributes) { { title: "Abstract Art", prompt: "Create abstract art with bold colors" } }
  let(:invalid_attributes) { { title: "", prompt: "" } }

  describe "GET /styles" do
    context "when no styles exist" do
      it "returns successful response" do
        get styles_path
        expect(response).to have_http_status(:success)
      end

      it "displays empty state message" do
        get styles_path
        expect(response.body).to include("No styles yet")
        expect(response.body).to include("Get started by creating your first style template")
      end

      it "includes create new style button" do
        get styles_path
        expect(response.body).to include("Create New Style")
        expect(response.body).to include("Create Your First Style")
      end
    end

    context "when styles exist" do
      let!(:styles) { create_list(:style, 3, title: "Test Style", prompt: "Test prompt") }

      it "returns successful response" do
        get styles_path
        expect(response).to have_http_status(:success)
      end

      it "displays all styles in the response" do
        get styles_path
        styles.each do |style|
          expect(response.body).to include(style.title)
          expect(response.body).to include(style.prompt)
        end
      end

      it "includes action links for each style" do
        get styles_path
        expect(response.body).to include("View")
        expect(response.body).to include("Edit")
        expect(response.body).to include("Delete")
      end

      it "includes page header and navigation" do
        get styles_path
        expect(response.body).to include("Styles")
        expect(response.body).to include("Manage your AI image generation styles")
      end
    end
  end

  describe "GET /styles/:id" do
    context "when style exists" do
      it "returns successful response" do
        get style_path(style)
        expect(response).to have_http_status(:success)
      end

      it "displays the style details" do
        get style_path(style)
        expect(response.body).to include(style.title)
        expect(response.body).to include(style.prompt)
      end
    end

    context "when style does not exist" do
      it "raises ActiveRecord::RecordNotFound" do
        expect {
          get style_path(id: 999999)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "GET /styles/new" do
    it "returns successful response" do
      get new_style_path
      expect(response).to have_http_status(:success)
    end

    it "displays the new style form" do
      get new_style_path
      expect(response.body).to include("Create New Style")
      expect(response.body).to include("form")
      expect(response.body).to include("title")
      expect(response.body).to include("prompt")
    end

    it "includes form fields and labels" do
      get new_style_path
      expect(response.body).to include('name="style[title]"')
      expect(response.body).to include('name="style[prompt]"')
      expect(response.body).to include("Create Style")
    end
  end

  describe "POST /styles" do
    context "with valid parameters" do
      it "creates a new style and redirects" do
        expect {
          post styles_path, params: { style: valid_attributes }
        }.to change(Style, :count).by(1)

        expect(response).to have_http_status(:redirect)
        follow_redirect!
        expect(response.body).to include(valid_attributes[:title])
        expect(response.body).to include(valid_attributes[:prompt])
      end

      it "sets a success flash message" do
        post styles_path, params: { style: valid_attributes }
        follow_redirect!
        expect(response.body).to include('Style was successfully created')
      end

      it "creates style with correct attributes" do
        post styles_path, params: { style: valid_attributes }
        created_style = Style.last
        expect(created_style.title).to eq(valid_attributes[:title])
        expect(created_style.prompt).to eq(valid_attributes[:prompt])
      end
    end

    context "with invalid parameters" do
      it "does not create a new style" do
        expect {
          post styles_path, params: { style: invalid_attributes }
        }.not_to change(Style, :count)
      end

      it "returns unprocessable entity status and shows form again" do
        post styles_path, params: { style: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Create New Style")
        expect(response.body).to include("form")
      end

      it "displays validation errors" do
        post styles_path, params: { style: invalid_attributes }
        expect(response.body).to include("error")
      end
    end
  end

  describe "GET /styles/:id/edit" do
    context "when style exists" do
      it "returns successful response" do
        get edit_style_path(style)
        expect(response).to have_http_status(:success)
      end

      it "displays the edit form with current values" do
        get edit_style_path(style)
        expect(response.body).to include("Edit")
        expect(response.body).to include(style.title)
        expect(response.body).to include(style.prompt)
        expect(response.body).to include("form")
      end

      it "includes form fields populated with existing data" do
        get edit_style_path(style)
        expect(response.body).to include('name="style[title]"')
        expect(response.body).to include('name="style[prompt]"')
        expect(response.body).to include(style.title)
      end
    end

    context "when style does not exist" do
      it "raises ActiveRecord::RecordNotFound" do
        expect {
          get edit_style_path(id: 999999)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "PATCH /styles/:id" do
    context "with valid parameters" do
      let(:new_attributes) { { title: "Updated Title", prompt: "Updated prompt" } }

      it "updates the style and redirects" do
        patch style_path(style), params: { style: new_attributes }
        expect(response).to have_http_status(:redirect)

        style.reload
        expect(style.title).to eq(new_attributes[:title])
        expect(style.prompt).to eq(new_attributes[:prompt])

        follow_redirect!
        expect(response.body).to include(new_attributes[:title])
      end

      it "sets a success flash message" do
        patch style_path(style), params: { style: new_attributes }
        follow_redirect!
        expect(response.body).to include('Style was successfully updated')
      end
    end

    context "with invalid parameters" do
      it "does not update the style" do
        original_title = style.title
        patch style_path(style), params: { style: invalid_attributes }
        style.reload
        expect(style.title).to eq(original_title)
      end

      it "returns unprocessable entity status and shows form again" do
        patch style_path(style), params: { style: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Edit")
        expect(response.body).to include("form")
      end

      it "displays validation errors" do
        patch style_path(style), params: { style: invalid_attributes }
        expect(response.body).to include("error")
      end
    end

    context "when style does not exist" do
      it "raises ActiveRecord::RecordNotFound" do
        expect {
          patch style_path(id: 999999), params: { style: valid_attributes }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "DELETE /styles/:id" do
    context "when style exists" do
      let!(:style_to_delete) { create(:style) }

      it "destroys the style and redirects to index" do
        expect {
          delete style_path(style_to_delete)
        }.to change(Style, :count).by(-1)

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(styles_url)
      end

      it "sets a success flash message" do
        delete style_path(style_to_delete)
        follow_redirect!
        expect(response.body).to include('Style was successfully deleted')
      end

      it "removes the style from the database" do
        style_id = style_to_delete.id
        delete style_path(style_to_delete)
        expect(Style.find_by(id: style_id)).to be_nil
      end
    end

    context "when style does not exist" do
      it "raises ActiveRecord::RecordNotFound" do
        expect {
          delete style_path(id: 999999)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "Parameter filtering" do
    it "only accepts permitted parameters" do
      malicious_params = {
        style: {
          title: "Test Style",
          prompt: "Test prompt",
          malicious_param: "should be filtered",
          id: 999,
          created_at: Time.current
        }
      }

      post styles_path, params: malicious_params
      created_style = Style.last

      expect(created_style.title).to eq("Test Style")
      expect(created_style.prompt).to eq("Test prompt")
      expect(created_style.id).not_to eq(999) # Should get auto-assigned ID
    end
  end
end
