ActiveAdmin.register AdminUser do
  permit_params :email, :password, :password_confirmation

  # Add this controller section to handle Ransack authorization
  controller do
    def apply_filtering(chain)
      @search = chain.ransack(params[:q] || {})
      @search.result
    end
  end

  index do
    selectable_column
    id_column
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs do
      f.input :email
      if f.object.new_record? # Only show password fields for new records
        f.input :password
        f.input :password_confirmation
      end
    end
    f.actions
  end

  # Add these methods to explicitly define searchable attributes
  controller do
    private

    def ransackable_attributes(auth_object = nil)
      %w[id email current_sign_in_at sign_in_count created_at updated_at]
    end

    def ransackable_associations(auth_object = nil)
      []
    end
  end
end