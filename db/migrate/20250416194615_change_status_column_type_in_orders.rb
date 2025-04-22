class ChangeStatusColumnTypeInOrders < ActiveRecord::Migration[6.1]
  def change
    # First, remove any existing default
    change_column_default :orders, :status, from: nil, to: nil

    # Then change the column type and set default
    change_column :orders, :status, :integer, using: 'status::integer', default: 0
  end
end