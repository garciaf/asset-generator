require 'rails_helper'

RSpec.describe Variation, type: :model do
  let(:image) { create(:image) }

  describe "associations" do
    it { should belong_to(:image) }
    it { should have_one(:variation_request).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:image) }

    context "when creating a new variation" do
      it "requires a file" do
        variation = build(:variation, image: image, file: nil)
        expect(variation).to_not be_valid
        expect(variation.errors[:file]).to include("can't be blank")
      end
    end

    context "when updating an existing variation" do
      it "does not require a file" do
        variation = create(:variation, image: image)
        variation.file = nil
        expect(variation).to be_valid
      end
    end
  end

  describe "file validation" do
    let(:variation) { build(:variation, image: image) }

    it "accepts valid image formats" do
      %w[image/png image/jpg image/jpeg image/gif image/webp].each do |content_type|
        file = double("file", attached?: true, content_type: content_type)
        allow(variation).to receive(:file).and_return(file)
        variation.valid?
        expect(variation.errors[:file]).to be_empty
      end
    end

    it "rejects invalid file formats" do
      file = double("file", attached?: true, content_type: "application/pdf")
      allow(variation).to receive(:file).and_return(file)
      variation.valid?
      expect(variation.errors[:file]).to include("must be an image file (PNG, JPG, JPEG, GIF, or WebP)")
    end
  end
end
