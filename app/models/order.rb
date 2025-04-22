class Order < ApplicationRecord
  belongs_to :customer, class_name: 'User', foreign_key: :user_id
  has_many :order_items, dependent: :destroy
  has_many :books, through: :order_items

  enum :status, {
    pending: 0,
    completed: 1,
    cancelled: 2
  }, default: :pending

  validates :shipping_address, :billing_address, :province, presence: true
  validates :total_price, numericality: { greater_than_or_equal_to: 0 }
  validates :gst, :pst, :hst, numericality: { greater_than_or_equal_to: 0 }

  PROVINCE_TAXES = {
    "AB" => { gst: 0.05, pst: 0.0, hst: 0.0 },
    "BC" => { gst: 0.05, pst: 0.07, hst: 0.0 },
    "MB" => { gst: 0.05, pst: 0.07, hst: 0.0 },
    "NB" => { gst: 0.0, pst: 0.0, hst: 0.15 },
    "NL" => { gst: 0.0, pst: 0.0, hst: 0.15 },
    "NS" => { gst: 0.0, pst: 0.0, hst: 0.15 },
    "NT" => { gst: 0.05, pst: 0.0, hst: 0.0 },
    "NU" => { gst: 0.05, pst: 0.0, hst: 0.0 },
    "ON" => { gst: 0.0, pst: 0.0, hst: 0.13 },
    "PE" => { gst: 0.0, pst: 0.0, hst: 0.15 },
    "QC" => { gst: 0.05, pst: 0.09975, hst: 0.0 },
    "SK" => { gst: 0.05, pst: 0.06, hst: 0.0 },
    "YT" => { gst: 0.05, pst: 0.0, hst: 0.0 }
  }.freeze

  # Add this ransacker to handle the customer_id filter
  ransacker :customer_id do
    Arel.sql("user_id")
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[billing_address created_at customer_notes gst hst id province pst shipping_address
       status subtotal total_price updated_at user_id customer_id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[books customer order_items]
  end

  def subtotal
    order_items.sum { |item| item.price * item.quantity }
  end

  def calculate_totals(cart_items = {}, books = [])
    subtotal_value = calculate_subtotal(cart_items, books)
    calculate_taxes(subtotal_value)
    self.total_price = subtotal_value + gst + pst + hst
  end

  def tax_total
    gst + pst + hst
  end

  def grand_total
    subtotal + tax_total
  end

  def product_names
    books.map(&:name).join(', ')
  end

  private

  def calculate_subtotal(cart_items, books)
    return order_items.sum { |item| item.price * item.quantity } if persisted?

    books.sum do |book|
      book.price * (cart_items[book.id] || 0)
    end
  end

  def calculate_taxes(subtotal_value)
    rates = PROVINCE_TAXES[province] || PROVINCE_TAXES["ON"]
    self.gst = subtotal_value * rates[:gst]
    self.pst = subtotal_value * rates[:pst]
    self.hst = subtotal_value * rates[:hst]
  end
end