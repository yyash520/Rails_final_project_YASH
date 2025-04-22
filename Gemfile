source "https://rubygems.org"

gem "rails", "~> 8.0.2"
# Keep propshaft but add sprockets for ActiveAdmin compatibility
gem "propshaft"
gem "sprockets-rails" # Required for ActiveAdmin assets
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"

gem "tzinfo-data", platforms: %i[ windows jruby ]

gem "solid_cache"
gem "solid_queue"
gem "solid_cable"
gem 'sqlite3'
gem 'faker'
gem 'csv'
gem 'kaminari'
gem 'browser'

# ActiveAdmin with required dependencies
gem 'activeadmin'
gem 'arbre' # Required by ActiveAdmin
gem 'formtastic' # Required by ActiveAdmin
gem 'ransack' # Required for search functionality

gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end

gem "devise", "~> 4.9"
gem "activestorage"
gem 'activerecord'
gem 'sassc'
gem 'activeadmin_quill_editor'
gem 'activeadmin-searchable_select'