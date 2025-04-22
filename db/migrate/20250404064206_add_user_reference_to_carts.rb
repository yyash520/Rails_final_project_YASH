class AddUserReferenceToCarts < ActiveRecord::Migration[6.1]
  def change
    add_reference :carts, :user, foreign_key: true, null: true # null: true allows guest carts
  end
end