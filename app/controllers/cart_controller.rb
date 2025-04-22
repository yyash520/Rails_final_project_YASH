class CartController < ApplicationController
  before_action :initialize_cart
  before_action :set_book, only: [:add, :remove]

  def show
    cart_session = session[:cart] || {}
    book_ids = cart_session.keys.map(&:to_i)

    # Load books with quantities > 0
    @cart_books = Book.where(id: book_ids).map do |book|
      quantity = cart_session[book.id.to_s].to_i
      quantity > 0 ? { book: book, quantity: quantity } : nil
    end.compact

    # Clean up session by removing invalid/zero quantity items
    session[:cart] = @cart_books.each_with_object({}) do |item, hash|
      hash[item[:book].id.to_s] = item[:quantity]
    end

    # Calculate total price
    @total_price = @cart_books.sum { |item| item[:book].price * item[:quantity] }
  end

  def add
    quantity = [params[:quantity].to_i, 1].max # Ensure at least quantity of 1
    session[:cart][@book.id.to_s] = quantity
    redirect_to cart_path, notice: "#{@book.title} added to cart!"
  end

  def remove
    session[:cart].delete(@book.id.to_s)
    redirect_to cart_path, notice: "#{@book.title} removed from cart"
  end

  def destroy
    session[:cart] = {}
    redirect_to cart_path, notice: "Cart cleared"
  end

  private

  def initialize_cart
    session[:cart] ||= {}
  end

  def set_book
    @book = Book.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to books_path, alert: "Book not found"
  end
end
