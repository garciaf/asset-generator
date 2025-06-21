class AddImageAndPromptToVariationRequests < ActiveRecord::Migration[8.0]
  def change
    add_reference :variation_requests, :image, null: false, foreign_key: true
    add_column :variation_requests, :prompt, :text
  end
end
