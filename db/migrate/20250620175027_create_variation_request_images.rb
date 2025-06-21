class CreateVariationRequestImages < ActiveRecord::Migration[8.0]
  def change
    create_table :variation_request_images do |t|
      t.references :variation_request, null: false, foreign_key: true
      t.references :image, null: false, foreign_key: true

      t.timestamps
    end
  end
end
