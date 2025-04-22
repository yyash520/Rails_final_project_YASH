# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      # Database authenticatable
      unless column_exists?(:users, :email)
        t.string :email, null: false, default: ""
      end
      unless column_exists?(:users, :encrypted_password)
        t.string :encrypted_password, null: false, default: ""
      end

      # Recoverable
      unless column_exists?(:users, :reset_password_token)
        t.string   :reset_password_token
      end
      unless column_exists?(:users, :reset_password_sent_at)
        t.datetime :reset_password_sent_at
      end

      # Rememberable
      unless column_exists?(:users, :remember_created_at)
        t.datetime :remember_created_at
      end

      # Trackable (optional)
      # unless column_exists?(:users, :sign_in_count)
      #   t.integer  :sign_in_count, default: 0, null: false
      #   t.datetime :current_sign_in_at
      #   t.datetime :last_sign_in_at
      #   t.string   :current_sign_in_ip
      #   t.string   :last_sign_in_ip
      # end

      # Confirmable (optional)
      # unless column_exists?(:users, :confirmation_token)
      #   t.string   :confirmation_token
      #   t.datetime :confirmed_at
      #   t.datetime :confirmation_sent_at
      #   t.string   :unconfirmed_email # Only if using reconfirmable
      # end

      # Lockable (optional)
      # unless column_exists?(:users, :failed_attempts)
      #   t.integer  :failed_attempts, default: 0, null: false
      #   t.string   :unlock_token
      #   t.datetime :locked_at
      # end

      t.timestamps null: false
    end

    add_index :users, :email, unique: true
    add_index :users, :reset_password_token, unique: true
    # add_index :users, :confirmation_token, unique: true
    # add_index :users, :unlock_token, unique: true
  end
end
