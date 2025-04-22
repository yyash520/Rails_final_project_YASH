class AddDeviseToAdminUsers < ActiveRecord::Migration[6.0]
  def change
    change_table :admin_users do |t|
      # Database authenticatable
      unless column_exists?(:admin_users, :email)
        t.string :email, default: "", null: false
      end
      unless column_exists?(:admin_users, :encrypted_password)
        t.string :encrypted_password, default: "", null: false
      end

      # Recoverable
      unless column_exists?(:admin_users, :reset_password_token)
        t.string :reset_password_token
      end
      unless column_exists?(:admin_users, :reset_password_sent_at)
        t.datetime :reset_password_sent_at
      end

      # Rememberable
      unless column_exists?(:admin_users, :remember_created_at)
        t.datetime :remember_created_at
      end

      # Optional Trackable
      # unless column_exists?(:admin_users, :sign_in_count)
      #   t.integer :sign_in_count, default: 0, null: false
      #   t.datetime :current_sign_in_at
      #   t.datetime :last_sign_in_at
      #   t.string :current_sign_in_ip
      #   t.string :last_sign_in_ip
      # end

      # Optional Confirmable
      # unless column_exists?(:admin_users, :confirmation_token)
      #   t.string :confirmation_token
      #   t.datetime :confirmed_at
      #   t.datetime :confirmation_sent_at
      #   t.string :unconfirmed_email
      # end

      # Optional Lockable
      # unless column_exists?(:admin_users, :failed_attempts)
      #   t.integer :failed_attempts, default: 0, null: false
      #   t.string :unlock_token
      #   t.datetime :locked_at
      # end
    end

    # Adding indices (if not already added)
    unless index_exists?(:admin_users, :email)
      add_index :admin_users, :email, unique: true
    end
    unless index_exists?(:admin_users, :reset_password_token)
      add_index :admin_users, :reset_password_token, unique: true
    end
    # Uncomment for optional fields
    # add_index :admin_users, :confirmation_token, unique: true
    # add_index :admin_users, :unlock_token, unique: true
  end
end
