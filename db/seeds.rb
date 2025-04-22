require 'csv'
require 'faker'

# Clear existing data safely
[OrderItem, Order, Book, Category].each do |model|
  model.destroy_all if ActiveRecord::Base.connection.table_exists?(model.table_name)
end

# Create admin user
AdminUser.find_or_create_by!(email: "admin@example.com") do |admin|
  admin.password = "password"
  admin.password_confirmation = "password"
end

# Import books from CSV
csv_path = Rails.root.join("books_scraped.csv")
book_count = 0
categories = {}

if File.exist?(csv_path)
  CSV.foreach(csv_path, headers: true) do |row|
    begin
      category_name = row["Book_category"] || "Uncategorized"
      category = categories[category_name] ||= Category.find_or_create_by!(name: category_name)

      Book.create!(
        title: row["Title"],
        author: row["Author"] || "Unknown Author",
        price: row["Price"].to_f,
        stock: row["Stock"].to_i,
        category: category
      )
      book_count += 1
    rescue => e
      puts "⚠️ Failed to create book: #{e.message}"
    end
  end
  puts "✅ Successfully imported #{book_count} books from CSV"
else
  puts "⚠️ books_scraped.csv not found in #{csv_path}"
end

# Ensure at least 100 products
if book_count < 100
  remaining = 100 - book_count
  category_ids = Category.pluck(:id)

  remaining.times do
    Book.create!(
      title: Faker::Book.title,
      author: Faker::Book.author,
      price: Faker::Commerce.price(range: 5.0..50.0),
      stock: rand(5..50),
      category_id: category_ids.sample
    )
  end
  puts "✅ Added #{remaining} extra books using Faker to reach 100 total"
end