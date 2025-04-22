class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status, default: 'pending' # Set default status to 'pending'
      t.decimal :total_price, precision: 10, scale: 2 # Set precision and scale for decimals

      t.timestamps
    end
  end
end
