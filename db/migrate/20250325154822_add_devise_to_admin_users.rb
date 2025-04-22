class AddDeviseToAdminUsers < ActiveRecord::Migration[6.0]
  def change
    change_table :admin_users do |t|
      # Avoid adding the column if it already exists
      unless column_exists?(:admin_users, :email)
        t.string :email, default: "", null: false
      end
      unless column_exists?(:admin_users, :encrypted_password)
        t.string :encrypted_password, default: "", null: false
      end
      unless column_exists?(:admin_users, :reset_password_token)
        t.string :reset_password_token
      end
      unless column_exists?(:admin_users, :reset_password_sent_at)
        t.datetime :reset_password_sent_at
      end
      unless column_exists?(:admin_users, :remember_created_at)
        t.datetime :remember_created_at
      end
    end

    # Add indexes for the Devise columns if they don't already exist
    unless index_exists?(:admin_users, :email)
      add_index :admin_users, :email, unique: true
    end
    unless index_exists?(:admin_users, :reset_password_token)
      add_index :admin_users, :reset_password_token, unique: true
    end
  end
end
