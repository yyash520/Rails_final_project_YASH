class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.timestamps
    end

    # Add a unique index on the name column to ensure uniqueness
    add_index :categories, :name, unique: true
  end
end
