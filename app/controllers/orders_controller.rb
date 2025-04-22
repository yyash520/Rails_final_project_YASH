class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_cart_not_empty, only: [:checkout, :create]
  before_action :load_cart_items, only: [:checkout, :create]

  def new
    @order = Order.new
  end

  def checkout
    @order = Order.new(
      shipping_address: current_user.address,
      billing_address: current_user.address,
      province: current_user.province
    )
    calculate_preliminary_totals
  end

  def create
    ActiveRecord::Base.transaction do
      @order = current_user.orders.build(order_params)
      @order.status = :pending

      build_order_items_from_cart
      @order.calculate_totals

      if @order.save!
        update_book_stocks
        clear_cart
        redirect_to order_path(@order), notice: "Order placed successfully!"
        return
      end
    end

    render :checkout, status: :unprocessable_entity
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Order failed: #{e.message}"
    flash.now[:alert] = "Order failed: #{e.record.errors.full_messages.to_sentence}"
    render :checkout, status: :unprocessable_entity
  rescue => e
    Rails.logger.error "Order processing error: #{e.message}\n#{e.backtrace.join("\n")}"
    flash.now[:alert] = "An unexpected error occurred while processing your order"
    render :checkout, status: :unprocessable_entity
  end

  def show
    @order = current_user.orders.find(params[:id])
    @order_items = @order.order_items.includes(:book)
  end

  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  private

  def order_params
    params.require(:order).permit(
      :shipping_address,
      :billing_address,
      :province,
      :customer_notes
    )
  end

  def ensure_cart_not_empty
    return unless current_user.cart.line_items.empty?
    redirect_to cart_path, alert: "Your cart is empty"
  end

  def load_cart_items
    @cart_items = current_user.cart.line_items.includes(:book)
    @subtotal = @cart_items.sum { |item| item.book.price * item.quantity }
  end

  def calculate_preliminary_totals
    @order ||= Order.new
    @order.calculate_totals
    @tax_rates = Order::PROVINCE_TAXES[@order.province] || Order::PROVINCE_TAXES[Order::DEFAULT_PROVINCE]
  end

  def build_order_items_from_cart
    @cart_items.each do |item|
      @order.order_items.build(
        book: item.book,
        quantity: item.quantity,
        price: item.book.price
      )
    end
  end

  def update_book_stocks
    @order.order_items.each do |item|
      item.book.decrement!(:stock, item.quantity)
    end
  end

  def clear_cart
    current_user.cart.line_items.destroy_all
  end
end