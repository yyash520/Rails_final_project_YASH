class AddAddressesToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :shipping_address, :text
    add_column :orders, :billing_address, :text
  end
end
