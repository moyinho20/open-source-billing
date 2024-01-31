class CreateVendors < ActiveRecord::Migration[6.0]
  def change
    create_table :vendors do |t|
      t.string "name"
      t.string "email"
      t.string "pan"
      t.timestamps
    end
  end
end
