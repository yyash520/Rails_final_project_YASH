class AddDetailsToOrderItems < ActiveRecord::Migration[8.0]
  def change
    add_reference :order_items, :book, null: false, foreign_key: true
    add_column :order_items, :quantity, :integer
    add_column :order_items, :price, :decimal
  end
end
