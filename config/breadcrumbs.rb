# config/breadcrumbs.rb

crumb :root do
  link "Home", root_path
end

crumb :categories do
  link "Categories", categories_path
  parent :root
end

crumb :category do |category|
  link category.name, category_path(category)
  parent :categories
end

crumb :product do |product|
  link product.title, product_path(product)
  parent :category, product.category
end

crumb :checkout do
  link "Checkout", checkout_path
  parent :root
end
