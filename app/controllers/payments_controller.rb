class PaymentsController < ApplicationController
  def create
    @order = Order.find(params[:order_id])
    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency: 'usd',
          product_data: { name: "Order ##{@order.id}" },
          unit_amount: (@order.total_price * 100).to_i
        },
        quantity: 1
      }],
      mode: 'payment',
      success_url: order_url(@order),
      cancel_url: root_url
    )
    redirect_to session.url, allow_other_host: true
  end
end
