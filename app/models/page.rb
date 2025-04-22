
class Page < ApplicationRecord
  # Add this method to specify searchable attributes
  def self.ransackable_attributes(auth_object = nil)
    # List all attributes you want to be searchable
    ["title", "slug", "content", "created_at", "updated_at"]
  end

  # Optional: Specify which associations can be searched
  def self.ransackable_associations(auth_object = nil)
    []
  end
end
