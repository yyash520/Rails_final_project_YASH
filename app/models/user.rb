class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  has_many :orders
  has_many :reviews
  has_one :cart, dependent: :destroy, autosave: true

  # === VALIDATIONS ===

  # Removed first_name and last_name presence validation for sign-up
  # They can still exist in DB but are no longer required

  # Postal code is only required during checkout
  validates :address, :city, :province, :postal_code, presence: true, on: :checkout

  # Keep format validation, but allow blank (to avoid errors during sign-up)
  validates :postal_code, format: {
    with: /\A[A-Za-z]\d[A-Za-z][ -]?\d[A-Za-z]\d\z/,
    message: "should be in Canadian format (A1A 1A1)"
  }, allow_blank: true

  # === RANSACK CONFIGURATION FOR ACTIVEADMIN ===
  def self.ransackable_attributes(auth_object = nil)
    # Safe attributes to search in admin interface
    %w[
      email first_name last_name address city province
      postal_code country created_at updated_at role
    ] +
    # Devise attributes (excluding sensitive ones)
    %w[
      reset_password_sent_at remember_created_at
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    # Allow searching through these associations
    %w[orders reviews cart]
  end

  # === METHODS ===

  # Check if user is an admin
  def admin?
    role == 'admin'
  end

  # Initialize cart after user creation
  after_create :initialize_cart

  private

  def initialize_cart
    create_cart unless cart
  end

  # Optional methods for display (will still work if fields are present in DB)
  def full_name
    "#{first_name} #{last_name}"
  end

  def full_address
    "#{address}, #{city}, #{province}, #{postal_code}, #{country}"
  end
end