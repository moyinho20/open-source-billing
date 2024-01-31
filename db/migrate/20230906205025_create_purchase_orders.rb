class CreatePurchaseOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :purchase_orders do |t|
      t.decimal "net_total", precision: 10, scale: 2
      t.decimal "sgst", precision: 10, scale: 2
      t.decimal "cgst", precision: 10, scale: 2
      t.decimal "igst", precision: 10, scale: 2
      t.decimal "total_payable", precision: 10, scale: 2
      t.timestamps
    end
  end
end
