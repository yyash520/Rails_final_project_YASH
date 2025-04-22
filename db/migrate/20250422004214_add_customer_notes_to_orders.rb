class AddCustomerNotesToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :customer_notes, :text
  end
end
