ActiveAdmin.register Book do
  permit_params :title, :author, :price, :stock, :category_id, :description, images: []

  index do
    selectable_column
    id_column
    column :title
    column :author
    column :price
    column :stock
    column :category
    column :created_at
    actions
  end

  filter :title
  filter :author
  filter :price
  filter :category
  filter :created_at

  form do |f|
    f.inputs do
      f.input :title
      f.input :author
      f.input :price
      f.input :stock
      f.input :category
      f.input :images, as: :file, input_html: { multiple: true }
    end
    f.actions
  end

  show do
    attributes_table do
      row :title
      row :author
      row :price
      row :stock
      row :category
      row :created_at
      row :images do
        div do
          book.images.each do |img|
            div do
              image_tag url_for(img), width: 100
            end
          end
        end
      end
    end
  end
end