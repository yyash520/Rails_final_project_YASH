ActiveAdmin.register Order do
  permit_params :user_id, :shipping_address, :billing_address, :province,
                :status, :customer_notes, :subtotal, :total_price,
                :gst, :pst, :hst,
                order_items_attributes: [:id, :book_id, :quantity, :price, :_destroy]

  # Filters configuration
  filter :user_id, as: :select,
         collection: -> { User.all.map { |u| [u.email, u.id] } },
         label: "Customer"
  filter :status, as: :select, collection: Order.statuses.keys
  filter :province, as: :select, collection: Order::PROVINCE_TAXES.keys
  filter :total_price
  filter :created_at

  # Index page configuration
  index do
    selectable_column
    column :id
    column "Customer" do |order|
      order.customer&.email || "Guest"
    end
    column :status do |order|
      status_tag order.status, class: "status-#{order.status}"
    end
    column("Total") { |order| number_to_currency(order.total_price) }
    column :province
    column :created_at
    actions
  end

  # Show page configuration
  show do
    attributes_table do
      row("Customer") { |order| order.customer&.email || "Guest" }
      row :status
      row :shipping_address
      row :billing_address
      row :province
      row("Subtotal") { number_to_currency(order.subtotal) }
      row("GST") { number_to_currency(order.gst) }
      row("PST") { number_to_currency(order.pst) }
      row("HST") { number_to_currency(order.hst) }
      row("Total") { number_to_currency(order.total_price) }
      row :created_at
      row :updated_at
    end

    panel "Order Items" do
      table_for order.order_items do
        column :book
        column :quantity
        column("Price Each") { |item| number_to_currency(item.price) }
        column("Total") { |item| number_to_currency(item.price * item.quantity) }
      end
    end
  end

  # Form configuration
  form do |f|
    f.inputs "Order Details" do
      f.input :user, as: :select,
              collection: User.all.map { |u| [u.email, u.id] },
              label: "Customer"
      f.input :status, as: :select, collection: Order.statuses.keys
      f.input :shipping_address
      f.input :billing_address
      f.input :province, as: :select, collection: Order::PROVINCE_TAXES.keys
      f.input :customer_notes
      f.input :subtotal
      f.input :gst
      f.input :pst
      f.input :hst
      f.input :total_price
    end

    f.inputs "Order Items" do
      f.has_many :order_items, allow_destroy: true do |item_f|
        item_f.input :book
        item_f.input :quantity
        item_f.input :price
      end
    end

    f.actions
  end

  # CSV export configuration
  csv do
    column :id
    column("Customer") { |order| order.customer&.email || "Guest" }
    column :status
    column("Total Price") { |order| order.total_price }
    column :province
    column :created_at
  end
end
