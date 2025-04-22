class AddTaxFieldsToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :province, :string
    add_column :orders, :gst, :decimal
    add_column :orders, :pst, :decimal
    add_column :orders, :hst, :decimal
  end
end
