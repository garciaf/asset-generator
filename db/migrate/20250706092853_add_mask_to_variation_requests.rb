class AddMaskToVariationRequests < ActiveRecord::Migration[8.0]
  def change
    add_column :variation_requests, :mask_data, :text
  end
end
