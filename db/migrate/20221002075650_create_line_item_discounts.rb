class CreateLineItemDiscounts < ActiveRecord::Migration[6.0]
  def change
    create_table :line_item_discounts do |t|
      t.references :invoice_line_item, foreign_key: true
      t.integer :discount_type
      t.decimal :amount
      t.timestamps
    end
  end
end
