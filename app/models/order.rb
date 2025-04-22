class Order < ApplicationRecord
  belongs_to :customer, class_name: 'User', foreign_key: :user_id
  has_many :order_items, dependent: :destroy
  has_many :books, through: :order_items

  accepts_nested_attributes_for :order_items, allow_destroy: true

  enum :status, {
    pending: 0,
    completed: 1,
    cancelled: 2
  }, default: :pending

  validates :shipping_address, :billing_address, :province, presence: true
  validates :total_price, numericality: { greater_than_or_equal_to: 0 }
  validates :gst, :pst, :hst, numericality: { greater_than_or_equal_to: 0 }
  validate :has_at_least_one_order_item

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
  }.with_indifferent_access.freeze

  DEFAULT_PROVINCE = "ON".freeze

  before_validation :set_default_status, if: :new_record?
  before_validation :calculate_totals_if_no_args, unless: :persisted?

  # Ransack configuration
  def self.ransackable_attributes(auth_object = nil)
    %w[billing_address created_at customer_notes gst hst id province pst
       shipping_address status total_price updated_at user_id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[customer order_items books]
  end

  def subtotal
    order_items.sum { |item| (item.price || 0) * (item.quantity || 0) }
  end

  def calculate_totals(cart_items = nil, books = nil)
    if cart_items && books
      self.order_items = []
      subtotal_value = 0.0

      cart_items.each do |book_id, quantity|
        book = books.find { |b| b.id == book_id.to_i }
        next unless book

        quantity = quantity.to_i
        subtotal_value += book.price * quantity

        order_items.build(
          book: book,
          quantity: quantity,
          price: book.price
        )
      end
    else
      subtotal_value = subtotal
    end

    calculate_taxes(subtotal_value)
    self.total_price = (subtotal_value + tax_total).round(2)
  end

  def tax_total
    (gst.to_f + pst.to_f + hst.to_f).round(2)
  end

  def grand_total
    (subtotal + tax_total).round(2)
  end

  private

  def set_default_status
    self.status ||= :pending
  end

  def calculate_totals_if_no_args
    calculate_totals unless total_price.present?
  end

  def calculate_taxes(subtotal_value)
    province_key = province.to_s.upcase.presence || DEFAULT_PROVINCE
    rates = PROVINCE_TAXES.fetch(province_key, PROVINCE_TAXES[DEFAULT_PROVINCE])

    self.gst = (subtotal_value * rates.fetch(:gst, 0)).round(2)
    self.pst = (subtotal_value * rates.fetch(:pst, 0)).round(2)
    self.hst = (subtotal_value * rates.fetch(:hst, 0)).round(2)
  end

  def has_at_least_one_order_item
    errors.add(:base, "Order must have at least one item") if order_items.empty?
  end
end