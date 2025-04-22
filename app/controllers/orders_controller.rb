class OrdersController < ApplicationController
  before_action :authenticate_user!

  def new
    @order = Order.new
    # Preserved original new action (though it may not be used anymore)
  end

  def checkout
    @order = Order.new
  end

  def create
    @order = current_user.orders.build(order_params.merge(status: Order.statuses[:pending]))

    # Build order_items from cart
    cart_items = current_user.cart.line_items
    cart_items.each do |item|
      @order.order_items.build(
        book: item.book,
        quantity: item.quantity,
        price: item.book.price
      )
    end

    if @order.save
      # Clear cart after successful order
      cart_items.destroy_all
      session[:cart] = nil if session[:cart] # In case you're also using session cart

      redirect_to order_path(@order), notice: "Order placed successfully!"
    else
      render :new
    end
  end

  def show
    @order = Order.find(params[:id])
    @order_items = @order.order_items.includes(:book)

    # Tax logic can be re-calculated here if needed
    @gst = @order.total_price * 0.05
    @pst = 0 # Optional based on province
    @hst = 0 # Optional based on province
    # Or fetch from order if taxes were stored
  end

  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  private

  def calculate_total_price
    if session[:cart].present?
      session[:cart].sum { |book_id, quantity| Book.find(book_id).price * quantity }
    else
      current_cart.total_price
    end
  end

  def order_params
    params.require(:order).permit(:shipping_address, :billing_address, :province)
  end
end
