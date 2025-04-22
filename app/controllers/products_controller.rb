class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin!, only: [:new, :create, :edit, :update, :destroy]

  # GET /products
  def index
    @products = Product.includes(:category, images_attachments: :blob)
                      .order(created_at: :desc)
                      .page(params[:page])

    if params[:search].present?
      @products = @products.where("name LIKE ? OR description LIKE ?",
                                "%#{params[:search]}%",
                                "%#{params[:search]}%")
    end

    if params[:category_id].present?
      @products = @products.where(category_id: params[:category_id])
    end
  end

  # GET /products/1
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products
  def create
    @product = Product.new(product_params)

    if @product.save
      if params[:product][:images].present?
        params[:product][:images].each do |image|
          @product.images.attach(image)
        end
      end
      redirect_to @product, notice: 'Product was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /products/1
  def update
    if @product.update(product_params)
      if params[:product][:images].present?
        params[:product][:images].each do |image|
          @product.images.attach(image)
        end
      end
      redirect_to @product, notice: 'Product was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /products/1
  def destroy
    @product.destroy
    redirect_to products_url, notice: 'Product was successfully deleted.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def product_params
      params.require(:product).permit(:name, :description, :price, :stock_quantity,
                                     :category_id, :sku, images: [])
    end

    # Authenticate admin for protected actions
    def authenticate_admin!
      unless admin_signed_in?
        redirect_to root_path, alert: "You don't have permission to access this page."
      end
    end
end