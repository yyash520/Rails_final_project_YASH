ActiveAdmin.register Page do
  permit_params :title, :slug, :content

  # Show predefined pages at the top of the index
  index do
    column :title
    column :slug
    column :created_at
    actions
  end

  # Create form configuration
  form do |f|
    f.inputs 'Page Details' do
      f.input :title
      f.input :slug, hint: "Use 'about' for About page and 'contact' for Contact page"
      f.input :content, as: :quill_editor
    end
    f.actions
  end

  # Add controller actions
  controller do
    def scoped_collection
      # Ensure system pages always appear
      Page.where(slug: %w[about contact]).or(Page.where.not(slug: %w[about contact]))
    end

    # Move private methods inside controller block
    def create_default_pages
      return if Page.exists?(slug: 'about') || Page.exists?(slug: 'contact')

      Page.create!(
        title: 'About Us',
        slug: 'about',
        content: '<h2>Our Story</h2><p>Default about page content</p>'
      )
      Page.create!(
        title: 'Contact Us',
        slug: 'contact',
        content: '<h2>Get in Touch</h2><p>Default contact page content</p>'
      )
    end

    # Add after save callback
    def save_resource(object)
      super.tap do
        create_default_pages unless Page.exists?(slug: 'about') || Page.exists?(slug: 'contact')
      end
    end
  end
end