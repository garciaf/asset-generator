FactoryBot.define do
  factory :variation_request do
    prompt { "Show the character in a jumping pose" }

    after(:build) do |variation_request|
      image = create(:image, :with_file)
      variation_request.images << image
    end
  end
end
