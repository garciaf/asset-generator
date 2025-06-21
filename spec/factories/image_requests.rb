FactoryBot.define do
  factory :image_request do
    prompt { "Generate a landscape painting" }
    association :style
  end
end
