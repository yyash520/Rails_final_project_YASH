class ChangeStatusToIntegerInOrders < ActiveRecord::Migration[7.0]
  def up
    # Remove old string column
    remove_column :orders, :status

    # Add new integer column with default value
    add_column :orders, :status, :integer, default: 0, null: false
  end

  def down
    # Reverse the change
    remove_column :orders, :status
    add_column :orders, :status, :string
  end
end
