class CreateImageRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :image_requests do |t|
      t.text :prompt
      t.references :style, null: false, foreign_key: true
      t.references :image, null: true, foreign_key: true

      t.timestamps
    end
  end
end
