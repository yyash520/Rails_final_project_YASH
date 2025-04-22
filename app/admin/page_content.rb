ActiveAdmin.register PageContent do
  permit_params :page_type, :title, :content

  index do
    selectable_column
    id_column
    column :page_type
    column :title
    column "Content Preview" do |page|
      truncate(strip_tags(page.content), length: 50)
    end
    column :updated_at
    actions
  end

  filter :page_type
  filter :title
  filter :updated_at

  form do |f|
    f.inputs do
      f.input :page_type, as: :select, collection: ['about', 'contact', 'faq']
      f.input :title
      f.input :content, as: :quill_editor
    end
    f.actions
  end

  show do
    attributes_table do
      row :page_type
      row :title
      row :content do |page|
        raw page.content
      end
      row :created_at
      row :updated_at
    end
  end
end