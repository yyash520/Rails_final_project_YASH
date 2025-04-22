class BooksController < ApplicationController
  def index
    @books = Book.all

    # Existing filters (unchanged)
    if params[:category_id].present?
      @category = Category.find(params[:category_id])
      @books = @category.books
    elsif params[:search].present?
      search_term = "%#{params[:search]}%"
      @books = @books.where("title LIKE ? OR author LIKE ?", search_term, search_term)
    end

    # New filters
    if params[:filter] == 'new'
      @books = @books.new_arrivals
    elsif params[:filter] == 'updated'
      @books = @books.recently_updated
    end

    # Maintain existing pagination
    @books = @books.page(params[:page]).per(10)
  end

  def show
    @book = Book.find(params[:id])
  end
end