Rails.application.routes.draw do
  # route to user
  get 'users/view/:id' => 'users#show'
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks', registrations: 'users/registrations' }
  get 'users/:id/embedded' => 'users#embedded'
  resources :users, only: [:index, :show, :edit, :update, :destroy]

  # route to slide
  get 'slides/latest' => 'latest#index'
  get 'slides/popular' => 'popular#index'
  get 'slides/view/:id' => 'slides#show'
  get 'slides/index' => 'slides#index'
  get 'slides/download/:id' => 'slide_download#show'
  get 'slides/:id/download' => 'slide_download#show'
  get 'slides/embedded/:id' => 'player#show'
  get 'slides/embedded/:id/:page' => 'player#show'
  get 'slides/:id/embedded' => 'player#show'
  get 'slides/:id/embedded/:page' => 'player#show'
  resources :slides
  get 'slides/:id/:page' => 'slides#show'

  # route to player
  get 'player/v2/:id' => 'player#show_v2', as: :player_v2
  get 'player/v2/:id/:page' => 'player#show_v2'
  get 'player/:id' => 'player#show', as: :player
  get 'player/:id/:page' => 'player#show'

  # route to download
  get 'download/:id' => 'slide_download#show'

  resources :comments, only: [:create, :destroy]
  resources :categories, only: [:show]
  resources :slide_page_count, only: [:show]
  resources :search, only: [:index]
  resources :latest, only: [:index]
  resources :popular, only: [:index]
  resources :html_player, only: [:show]
  resources :slide_download, only: [:show]

  require 'username_url_constrainer'
  constraints(SlideHub::UsernameUrlConstrainer.new) do
    get ':username' => 'users#show', as: :user_by_username
    get ':username/statistics' => 'users#statistics', as: :statistics_by_username
    get ':username/embedded' => 'users#embedded', as: :user_embedded_by_username
  end

  get 'pages/:path' => 'pages#show'
  get 'statistics' => 'statistics#index'
  get 'statistics/index' => 'statistics#index'

  namespace :admin do
    resource :dashboard, only: [:show]
    resources :featured_slides, only: [:index, :new, :create, :destroy]
    resources :slides, only: [:index, :edit, :update]
    resources :slide_download, only: [:show]
    resources :slide_reconvert, only: [:show]
    resources :users, only: [:index, :edit, :update, :destroy]
    resources :categories, only: [:index, :new, :create, :edit, :update, :destroy]
    resources :custom_files, only: [:index, :new, :create, :destroy]
    resources :pages, only: [:index, :new, :create, :edit, :update, :destroy]
    resources :tenants, only: [:index, :new, :create, :edit, :update, :destroy]

    resources :custom_contents do
      get 'index', on: :collection
      post 'update', on: :collection, as: :update
    end

    resources :site_settings do
      get 'index', on: :collection
      post 'update', on: :collection, as: :update
    end

    get 'logs/index' => 'logs#index'
    get 'logs/show' => 'logs#show'
    get 'logs/download' => 'logs#download', as: :logs_download
  end

  namespace :api, { format: 'json' } do
    namespace :v1 do
      resources :slides, only: [:show, :index]
      resources :users, only: [:show]
      get 'slides/:id/transcript' => 'slides#transcript'
    end
  end

  namespace :custom, { format: 'css' } do
    get 'override' => 'css#show'
  end

  # config/routes.rb
  Rails.application.routes.draw do
    root 'slides#index'
  end
end
