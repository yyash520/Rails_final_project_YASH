ActiveAdmin.register User do
  permit_params :email, :first_name, :last_name, :address, :city, :province, :postal_code

  index do
    selectable_column
    id_column
    column :email
    column :first_name
    column :last_name
    column :created_at
    actions
  end

  filter :email
  filter :created_at

  form do |f|
    f.inputs do
      f.input :email
      f.input :first_name
      f.input :last_name
      f.input :address
      f.input :city
      f.input :province
      f.input :postal_code
    end
    f.actions
  end
end