class RemoveImageFromVariationRequests < ActiveRecord::Migration[8.0]
  def change
    remove_reference :variation_requests, :image, null: false, foreign_key: true
  end
end
