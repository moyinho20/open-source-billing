class AddAttributesToItems < ActiveRecord::Migration[6.0]
  def change
    add_column :items, :batch, :string
    add_column :items, :expiry, :string
    add_column :items, :hsn, :string
    add_column :items, :mrp, :decimal, precision: 10, scale: 2
    add_column :items, :ptr, :decimal, precision: 10, scale: 2
    add_column :items, :discount, :decimal, precision: 10, scale: 2
  end
end
