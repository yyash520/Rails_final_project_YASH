# app/models/province.rb
class Province < ApplicationRecord
  has_many :users
  validates :name, :code, presence: true
end