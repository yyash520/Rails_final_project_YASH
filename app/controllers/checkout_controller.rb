class CheckoutController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart_items, only: [:new, :create]
  before_action :initialize_cart_variables, only: [:new, :create]
  before_action :load_cart_items, only: [:new, :create]
  before_action :initialize_order, only: [:new]

  def new
    if @cart_items.empty?
      redirect_to cart_path, alert: "Your cart is empty. Please add items before checking out."
      return
    end

    @order ||= Order.new(
      customer: current_user,
      shipping_address: current_user.address,
      billing_address: current_user.address,
      province: current_user.province
    )

    calculate_order_totals
  end

  def create
    @cart_items = session[:cart] || {}
    if @cart_items.empty?
      redirect_to cart_path, alert: "Your cart is empty."
      return
    end

    @order = Order.new(order_params)
    @order.customer = current_user
    books = Book.where(id: @cart_items.keys)
    @order.calculate_totals(@cart_items, books)

    if @order.save
      begin
        process_order_items(@order, @cart_items)
        clear_cart # Clear the cart once order is placed successfully
        redirect_to order_path(@order), notice: "Order placed successfully!"
      rescue ActiveRecord::RecordInvalid => e
        @order.destroy # If error occurs, delete the order
        flash.now[:alert] = "Order failed: #{e.message}"
        render :new # Render the form again with error message
      end
    else
      flash.now[:alert] = "Order validation failed."
      render :new # Show errors and allow user to correct them
    end
  end

  def confirm
    @order = current_user.orders.includes(:order_items, :books).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Order not found."
  end

  def tax_rates
    province_code = params[:province]
    taxes = Order::PROVINCE_TAXES[province_code] || {}

    respond_to do |format|
      if taxes.present?
        format.json { render json: taxes }
      else
        format.json { render json: { error: "Invalid province code" }, status: :unprocessable_entity }
      end
    end
  end

  private

  def order_params
    params.require(:order).permit(
      :shipping_address,
      :billing_address,
      :province,
      :customer_notes,
      :subtotal,
      :gst,
      :pst,
      :hst,
      :total_price
    )
  end

  def set_cart_items
    cart_data = session[:cart] || {}
    @cart_items = cart_data.map do |book_id, quantity|
      { book_id: book_id.to_i, quantity: quantity.to_i }
    end
  end

  def initialize_cart_variables
    @valid_cart_items = @cart_items.each_with_object([]) do |item, arr|
      book = Book.find_by(id: item[:book_id])
      next unless book

      arr << {
        book: book,
        quantity: item[:quantity],
        price: book.price,
        total: book.price * item[:quantity]
      }
    end

    @subtotal = @valid_cart_items.sum { |item| item[:total] }
  end

  def load_cart_items
    @cart_items = (session[:cart] || {}).transform_keys(&:to_i)
    @books = Book.where(id: @cart_items.keys)
  end

  def initialize_order
    @order ||= current_user.orders.new(
      shipping_address: current_user.address,
      billing_address: current_user.address,
      province: current_user.province
    )
    calculate_order_totals
  end

  def calculate_order_totals
    return unless @cart_items.present? && @books.present?

    @order.calculate_totals(@cart_items, @books)
    @order.subtotal ||= @subtotal
    @order.total_price ||= @order.subtotal + @order.gst.to_f + @order.pst.to_f + @order.hst.to_f
  end

  def process_order_items(order, cart_items)
    ActiveRecord::Base.transaction do
      cart_items.each do |book_id, quantity|
        book = Book.find(book_id)
        new_stock = book.stock - quantity.to_i
        raise ActiveRecord::RecordInvalid.new(book), "Not enough stock" if new_stock < 0

        order.order_items.create!(
          book: book,
          quantity: quantity,
          price: book.price
        )

        book.update!(stock: new_stock)
      end
    end
  end

  def clear_cart
    session.delete(:cart)
    @cart_items = {}
  end
end
