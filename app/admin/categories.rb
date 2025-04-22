ActiveAdmin.register Category do
  permit_params :name, :description

  index do
    selectable_column
    id_column
    column :name
    column :description
    column "Number of Products" do |category|
      category.books.count
    end
    column :created_at
    actions
  end

  filter :name
  filter :created_at

  form do |f|
    f.inputs do
      f.input :name
      f.input :description
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :description
      row :created_at
      row :updated_at
      row "Products" do |category|
        ul do
          category.books.limit(5).each do |book|
            li link_to(book.title, admin_book_path(book))
          end
        end
      end
    end
  end
end