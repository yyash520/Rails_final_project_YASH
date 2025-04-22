class PageContent < ApplicationRecord
  validates :page_type, presence: true, uniqueness: true
  validates :title, :content, presence: true
end