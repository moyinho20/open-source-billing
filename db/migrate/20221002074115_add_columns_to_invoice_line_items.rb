class AddColumnsToInvoiceLineItems < ActiveRecord::Migration[6.0]
  def change
    add_column :invoice_line_items, :pack, :string
    add_column :invoice_line_items, :batch, :string
    add_column :invoice_line_items, :expiry, :string
    add_column :invoice_line_items, :hsn, :string
    add_column :invoice_line_items, :rate, :decimal
    add_column :invoice_line_items, :mrp, :decimal
  end
end
