class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :book

  validates :quantity, numericality: { greater_than: 0 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  # Allowlisted attributes for Ransack searching
  def self.ransackable_attributes(auth_object = nil)
    %w[id book_id order_id price quantity created_at updated_at]
  end

  # Allowlisted associations for Ransack searching
  def self.ransackable_associations(auth_object = nil)
    %w[book order]
  end
end