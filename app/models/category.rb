class Category < ApplicationRecord
  has_many :books, dependent: :nullify
  validates :name, presence: true, uniqueness: true

  def self.ransackable_attributes(auth_object = nil)
    %w[name created_at updated_at]
  end
end