class CreateItemStocks < ActiveRecord::Migration[6.0]
  def change
    create_table :item_stocks do |t|
      t.integer "available_quantity"
      t.references "item"
      t.timestamps
    end
  end
end
