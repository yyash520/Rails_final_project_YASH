class AddRoleToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :role, :string, default: 'customer'
    add_index :users, :role  # Optional: Add index for better performance
  end
end
