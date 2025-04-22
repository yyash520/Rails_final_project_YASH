class Product < ApplicationRecord
  belongs_to :category, optional: true
  has_many_attached :images

  validates :name, :price, presence: true
end