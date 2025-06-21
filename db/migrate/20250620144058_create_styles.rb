class CreateStyles < ActiveRecord::Migration[8.0]
  def change
    create_table :styles do |t|
      t.string :title
      t.text :prompt

      t.timestamps
    end
  end
end
