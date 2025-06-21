FactoryBot.define do
  factory :image do
    title { "Test Image" }
    description { "A test image for sprite generation" }
    
    trait :with_file do
      after(:build) do |image|
        # Create a minimal valid PNG file (1x1 pixel)
        png_data = "\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x02\x00\x00\x00\x90wS\xde\x00\x00\x00\tpHYs\x00\x00\x0b\x13\x00\x00\x0b\x13\x01\x00\x9a\x9c\x18\x00\x00\x00\nIDATx\x9cc```\x00\x00\x00\x04\x00\x01\xdd\x8d\xb4\x1c\x00\x00\x00\x00IEND\xaeB`\x82"
        image.file.attach(
          io: StringIO.new(png_data),
          filename: "test_image.png",
          content_type: "image/png"
        )
      end
    end
    
    trait :without_request do
      image_request { nil }
    end
  end
end
