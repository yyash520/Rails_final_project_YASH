class CreateReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.integer :rating, null: false, default: 1 # Add constraints for rating
      t.text :content

      t.timestamps
    end

    # Adding index for better query performance on user_id and book_id
    add_index :reviews, [:user_id, :book_id], unique: true

    # Optional: Add a check constraint for rating (1-5 scale)
    execute <<-SQL
      ALTER TABLE reviews
      ADD CONSTRAINT rating_check CHECK (rating >= 1 AND rating <= 5)
    SQL
  end
end
