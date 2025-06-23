FactoryBot.define do
  factory :variation do
    image

    after(:build) do |variation|
      variation.file.attach(
        io: File.open(Rails.root.join('spec', 'fixtures', 'test_image.png')),
        filename: 'test_image.png',
        content_type: 'image/png'
      )
    end
  end
end
