class AdminUser < ApplicationRecord
       # Include default Devise modules. Others available are:
       # :confirmable, :lockable, :timeoutable, :trackable, and :omniauthable
       devise :database_authenticatable,
              :recoverable,
              :rememberable,
              :validatable

       # Add these methods for Ransack/ActiveAdmin compatibility
       def self.ransackable_attributes(auth_object = nil)
         # Whitelist only safe, non-sensitive attributes for searching
         %w[id email created_at updated_at current_sign_in_at sign_in_count
            remember_created_at reset_password_sent_at]
       end

       def self.ransackable_associations(auth_object = nil)
         [] # No associations should be searchable through admin interface
       end
     end
