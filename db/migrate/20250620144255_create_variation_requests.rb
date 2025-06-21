class CreateVariationRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :variation_requests do |t|
      t.references :variation, null: true, foreign_key: true

      t.timestamps
    end
  end
end
