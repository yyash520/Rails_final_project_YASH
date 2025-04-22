class CheckoutController < ApplicationController
  before_action :authenticate_user!
  before_action :load_cart_data, only: [:new, :create]
  before_action :verify_cart_not_empty, only: [:new, :create]
  before_action :load_books_with_lock, only: [:create] # Changed to only create for performance
  before_action :initialize_order, only: [:new]

  def new
    load_books # Regular load for display purposes
    calculate_order_totals
  end

  def create
    ActiveRecord::Base.transaction do
      @order = build_order_with_items

      # Validate stock before saving
      validate_stock_availability

      if @order.save
        update_book_stocks
        clear_cart
        redirect_to order_path(@order), notice: "Order placed successfully!"
        return
      else
        raise ActiveRecord::Rollback, @order.errors.full_messages.to_sentence
      end
    end

    # Only reached if transaction fails
    load_books # Reload for the form
    flash.now[:alert] = @order.errors.full_messages.to_sentence.presence || "Order could not be placed"
    render :new
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Order validation failed: #{e.message}"
    flash.now[:alert] = e.record.errors.full_messages.to_sentence
    render :new
  rescue => e
    Rails.logger.error "Checkout Error: #{e.message}\n#{e.backtrace.join("\n")}"
    flash.now[:alert] = e.message
    render :new
  end

  private

  def load_cart_data
    @cart_items = (session[:cart] || {}).transform_values(&:to_i)
  end

  def verify_cart_not_empty
    return unless @cart_items.empty?
    redirect_to cart_path, alert: "Your cart is empty."
  end

  def load_books
    @books = Book.where(id: @cart_items.keys).index_by(&:id)
  end

  def load_books_with_lock
    @books = Book.lock.where(id: @cart_items.keys).index_by(&:id)
  end

  def initialize_order
    @order ||= current_user.orders.new(
      shipping_address: current_user.address,
      billing_address: current_user.address,
      province: current_user.province,
      status: :pending
    )
  end

  def calculate_order_totals
    @order.calculate_totals(@cart_items, @books.values)
  end

  def build_order_with_items
    order = current_user.orders.new(order_params)
    order.status = :pending

    @cart_items.each do |book_id, quantity|
      book = @books[book_id.to_i]
      next unless book

      order.order_items.build(
        book: book,
        quantity: quantity,
        price: book.price
      )
    end

    order.calculate_totals(@cart_items, @books.values)
    order
  end

  def validate_stock_availability
    @cart_items.each do |book_id, quantity|
      book = @books[book_id.to_i]
      if book.stock < quantity
        raise "Not enough stock for #{book.title}. Available: #{book.stock}, Requested: #{quantity}"
      end
    end
  end

  def update_book_stocks
    @order.order_items.each do |item|
      item.book.decrement!(:stock, item.quantity)
    end
  end

  def clear_cart
    session.delete(:cart)
    current_user.cart.line_items.destroy_all if current_user.cart.present?
  end

  def order_params
    params.require(:order).permit(
      :shipping_address,
      :billing_address,
      :province,
      :customer_notes
    )
  end
end