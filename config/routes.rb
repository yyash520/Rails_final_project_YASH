Rails.application.routes.draw do
  # Devise authentication for users and admin users
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # Static pages
  get "/pages/:title", to: "pages#show", as: :page
  get 'about', to: 'pages#about', as: :about_page
  get 'contact', to: 'pages#contact', as: :contact_page
  post 'contact', to: 'pages#contact_submit', as: :contact_submit

  # Books and Categories
  resources :books, only: [:index, :show] do
    collection do
      get :new_arrivals
      get :recently_updated
    end
  end
  resources :categories, only: [:index, :show]

  # Orders and Payments
  resources :orders, only: [:index, :show, :new, :create]
  resources :payments, only: [:create]

  # Shopping Cart (singular resource since there's only one cart per user)
  resource :cart, only: [:show, :destroy], controller: "cart" do
    post 'add/:id', to: 'cart#add', as: 'add_to_cart'
    delete 'remove/:id', to: 'cart#remove', as: :remove_from_cart
  end

  # Checkout flow
  get 'checkout/new', to: 'checkout#new', as: :new_checkout
  post 'checkout', to: 'checkout#create', as: :checkout
  get 'checkout/confirm/:id', to: 'checkout#confirm', as: :checkout_confirm
  get 'checkout/tax_rates', to: 'checkout#tax_rates'

  # Admin namespace
  namespace :admin do
    resources :books, except: [:show]
    resources :pages, except: [:show]
  end

  # Root path
  root "books#index"
end
