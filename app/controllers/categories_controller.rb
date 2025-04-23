def index
  add_breadcrumb "Categories", categories_path
  @categories = Category.all
end

def show
  @category = Category.find(params[:id])
  add_breadcrumb "Categories", categories_path
  add_breadcrumb @category.name, category_path(@category)
  @books = @category.books
end
