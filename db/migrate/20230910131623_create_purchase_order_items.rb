class CreatePurchaseOrderItems < ActiveRecord::Migration[6.0]
  def change
    create_table :purchase_order_items do |t|
      t.references "purchase_order_item"
      t.references "item"
      t.string "expiry"
      t.integer "quantity"
      t.decimal "rate", precision: 10, scale: 2
      t.decimal "cgst", precision: 10, scale: 2
      t.decimal "sgst", precision: 10, scale: 2
      t.decimal "igst", precision: 10, scale: 2
      t.decimal "total_payable", precision: 10, scale: 2
      t.string "mfg_by"
      t.timestamps
    end
  end
end
