class AddSlugToPages < ActiveRecord::Migration[8.0]
  def change
    add_column :pages, :slug, :string
  end
end
