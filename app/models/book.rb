class Book < ApplicationRecord
  belongs_to :category
  has_many_attached :images
  has_many :reviews, dependent: :destroy

  validates :title, :author, :price, :stock, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Add these methods for Ransack/ActiveAdmin
  def self.ransackable_attributes(auth_object = nil)
    # Allowlist of searchable attributes
    %w[title author price stock category_id created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    # Allowlist of searchable associations
    %w[category]
  end

  # New arrivals (created in last 3 days)
  scope :new_arrivals, -> { where('created_at >= ?', 3.days.ago) }

  # Recently updated (updated in last 3 days, excluding new arrivals)
  scope :recently_updated, -> {
    where('updated_at >= ? AND created_at < ?', 3.days.ago, 3.days.ago)
  }
end
