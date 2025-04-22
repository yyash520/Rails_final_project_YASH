require_relative "boot"

require "rails/all"
require "propshaft"


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MapleReads
  class Application < Rails::Application
    # Initialize configuration defaults for the Rails version you are using.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Ensure ActiveAdmin assets are included in the Propshaft asset pipeline.
    # This step is for asset loading in Propshaft, Rails' newer asset pipeline system.
    config.assets.paths << Rails.root.join("app/assets/stylesheets")
    config.assets.paths << Rails.root.join("app/assets/javascripts")

    # Propshaft does not use `precompile`, so remove the following line:
    # config.assets.precompile += %w( active_admin.css active_admin.js )

    # Additional configurations for the application, engines, and railties go here.
    # You can override any of these settings in specific environments in config/environments.
    #
    # Example configurations:
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
