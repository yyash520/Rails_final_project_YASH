class ApplicationController < ActionController::Base
  # Allow only modern browsers
  before_action :check_browser
  before_action :initialize_cart

  def index
    # Your index logic here
  end

  private

  def check_browser
    user_agent = request.user_agent
    if user_agent.include?("Chrome") || user_agent.include?("Firefox") || user_agent.include?("Safari")
      # Logic for modern browsers
    else
      # Logic for non-modern browsers (optional)
    end
  end

  # New cart methods (added below existing code)
  def initialize_cart
    @current_cart ||= current_cart
  end

  def current_cart
    if defined?(current_user) && current_user
      current_user.cart || current_user.create_cart
    else
      Cart.find(session[:cart_id]) rescue create_guest_cart
    end
  end
  helper_method :current_cart

  def create_guest_cart
    cart = Cart.create!
    session[:cart_id] = cart.id
    cart
  end
end