class Cart < ApplicationRecord
  has_many :line_items, dependent: :destroy
  belongs_to :user, optional: true # Important for guest carts
  # Validations
  validates :line_items, length: { maximum: 100, message: "cannot have more than 100 items" }

  # Instance Methods
  def total_price
    line_items.sum(&:total_price)
  end

  def item_count
    line_items.sum(:quantity)
  end

  def add_book(book, quantity = 1)
    current_item = line_items.find_by(book_id: book.id)

    if current_item
      current_item.quantity += quantity.to_i
    else
      current_item = line_items.build(
        book: book,
        price: book.price,
        quantity: quantity
      )
    end

    current_item.save!
    current_item
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to add book to cart: #{e.message}"
    nil
  end

  def remove_book(book, quantity = 1)
    current_item = line_items.find_by(book_id: book.id)
    return unless current_item

    if current_item.quantity > quantity.to_i
      current_item.quantity -= quantity.to_i
      current_item.save!
    else
      current_item.destroy
    end
  end

  def empty?
    line_items.empty?
  end

  def merge!(other_cart)
    other_cart.line_items.each do |item|
      add_book(item.book, item.quantity)
    end
    other_cart.destroy
  end
end