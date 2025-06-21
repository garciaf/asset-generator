require 'rails_helper'

RSpec.describe Style, type: :model do
  describe 'validations' do
    it 'requires a title' do
      style = Style.new(prompt: 'Test prompt for styling')
      expect(style).not_to be_valid
      expect(style.errors[:title]).to include("can't be blank")
    end

    it 'requires a prompt' do
      style = Style.new(title: 'Test Style')
      expect(style).not_to be_valid
      expect(style.errors[:prompt]).to include("can't be blank")
    end

    it 'validates title length' do
      style = Style.new(title: '', prompt: 'Test prompt for styling')
      expect(style).not_to be_valid
      expect(style.errors[:title]).to include('is too short (minimum is 1 character)')

      style.title = 'a' * 101
      expect(style).not_to be_valid
      expect(style.errors[:title]).to include('is too long (maximum is 100 characters)')
    end

    it 'validates prompt length' do
      style = Style.new(title: 'Test Style', prompt: 'short')
      expect(style).not_to be_valid
      expect(style.errors[:prompt]).to include('is too short (minimum is 10 characters)')

      style.prompt = 'a' * 2001
      expect(style).not_to be_valid
      expect(style.errors[:prompt]).to include('is too long (maximum is 2000 characters)')
    end

    it 'is valid with proper title and prompt' do
      style = Style.new(
        title: 'Digital Art Style',
        prompt: 'Create a digital art style with vibrant colors and modern aesthetics'
      )
      expect(style).to be_valid
    end
  end
end
