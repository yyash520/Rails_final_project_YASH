class AddSubtotalToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :subtotal, :decimal
  end
end
