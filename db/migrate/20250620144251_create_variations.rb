class CreateVariations < ActiveRecord::Migration[8.0]
  def change
    create_table :variations do |t|
      t.references :image, null: false, foreign_key: true

      t.timestamps
    end
  end
end
