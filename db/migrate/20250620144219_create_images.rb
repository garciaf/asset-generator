class CreateImages < ActiveRecord::Migration[8.0]
  def change
    create_table :images do |t|
      t.text :description
      t.string :title

      t.timestamps
    end
  end
end
