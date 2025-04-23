class CheckoutController < ApplicationController
  before_action :authenticate_user!, only: [:create, :confirm]
  before_action :load_cart_data, only: [:new, :create]
  before_action :verify_cart_not_empty, only: [:new, :create]
  before_action :load_books_with_lock, only: [:create]
  before_action :initialize_order, only: [:new]

  def new
    add_breadcrumb "Checkout", new_checkout_path
    load_books
    calculate_order_totals
    @provinces = Order::PROVINCE_TAXES.keys
  end

  def create
    removed_books = remove_out_of_stock_items
    if removed_books.any?
      @order = current_user.orders.new(order_params) if current_user
      @order ||= Order.new(order_params)
      flash.now[:alert] = "Sorry, the following items are out of stock and were removed from your cart: #{removed_books.join(', ')}"
      load_books
      @provinces = Order::PROVINCE_TAXES.keys
      render :new, status: :unprocessable_entity
      return
    end

    @order = nil
    begin
      ActiveRecord::Base.transaction do
        @order = build_order_with_items
        validate_stock_availability

        if @order.save
          update_book_stocks
          clear_cart
          OrderMailer.confirmation_email(@order).deliver_later if Rails.env.production?
          redirect_to checkout_confirm_path(@order), notice: "Order placed successfully!"
          return
        else
          Rails.logger.error "Order save failed: #{@order.errors.full_messages.to_sentence}"
          flash.now[:alert] = @order.errors.full_messages.to_sentence.presence || "Order could not be placed"
          raise ActiveRecord::Rollback
        end
      end
    rescue => e
      @order ||= current_user.orders.new(order_params) if current_user
      @order ||= Order.new(order_params)
      Rails.logger.error "Checkout Error: #{e.message}\n#{e.backtrace.join("\n")}"
      load_books
      @provinces = Order::PROVINCE_TAXES.keys
      flash.now[:alert] = e.message
      render :new, status: :unprocessable_entity
      return
    end

    handle_checkout_failure
  end

  def confirm
    @order = current_user.orders.includes(order_items: :book).find(params[:id])
    add_breadcrumb "Checkout", new_checkout_path
    add_breadcrumb "Confirmation", checkout_confirm_path(@order)
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Order not found."
  end

  private

  def load_cart_data
    @cart_items = (session[:cart] || {}).transform_values(&:to_i)
    @cart_total_items = @cart_items.values.sum
    @books = Book.where(id: @cart_items.keys).index_by(&:id)
    @cart_subtotal = calculate_cart_subtotal
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
    @order ||= if current_user
      current_user.orders.new(
        shipping_address: current_user.address,
        billing_address: current_user.address,
        province: current_user.province,
        status: :pending
      )
    else
      Order.new
    end
  end

  def calculate_order_totals
    @order.calculate_totals(@cart_items, @books.values)
    @tax_rates = Order::PROVINCE_TAXES[@order.province] || Order::PROVINCE_TAXES[Order::DEFAULT_PROVINCE]
  end

  def calculate_cart_subtotal
    @books.sum { |id, book| book.price * @cart_items[id.to_s] }
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
      if book.nil? || book.stock < quantity
        raise "Not enough stock for #{book&.title || 'unknown book'}. Available: #{book&.stock || 0}, Requested: #{quantity}"
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
    current_user.cart.line_items.destroy_all if current_user&.cart.present?
  end

  def handle_checkout_failure
    @order ||= current_user.orders.new(order_params) if current_user
    @order ||= Order.new(order_params)
    load_books
    @provinces = Order::PROVINCE_TAXES.keys
    flash.now[:alert] = @order.errors.full_messages.to_sentence.presence || "Order could not be placed"
    render :new, status: :unprocessable_entity
  end

  def order_params
    params.require(:order).permit(
      :shipping_address,
      :billing_address,
      :province,
      :customer_notes
    )
  end

  # Remove out-of-stock items from cart before attempting checkout
  def remove_out_of_stock_items
    removed = []
    @cart_items.each do |book_id, quantity|
      book = @books[book_id.to_i]
      if book.nil? || book.stock < quantity
        removed << (book&.title || "Book ##{book_id}")
        @cart_items.delete(book_id)
        session[:cart]&.delete(book_id)
      end
    end
    removed
  end
end
