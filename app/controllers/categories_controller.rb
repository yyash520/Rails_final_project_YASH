class CategoriesController < ApplicationController
  def index
    @categories = Category.all
  end

  def show
    @category = Category.find(params[:id])
    @books = @category.books  # Assuming Category has_many :books
  end
end
