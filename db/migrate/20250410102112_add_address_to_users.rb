class AddAddressToUsers < ActiveRecord::Migration[6.0]
  def change
    unless column_exists?(:users, :province)
      add_column :users, :province, :string
    end

    unless column_exists?(:users, :address)
      add_column :users, :address, :string
    end

    unless column_exists?(:users, :city)
      add_column :users, :city, :string
    end

    unless column_exists?(:users, :postal_code)
      add_column :users, :postal_code, :string
    end

    unless column_exists?(:users, :country)
      add_column :users, :country, :string
    end
  end
end
