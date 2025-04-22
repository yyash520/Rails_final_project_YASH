# config/initializers/assets.rb

# Add ActiveAdmin assets to precompile list
Rails.application.config.assets.precompile += %w( active_admin.css active_admin.js )
