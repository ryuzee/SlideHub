Rails.application.routes.draw do
  get 'search' => 'search#index'
  get 'latest' => 'latest_slides#index'
  get 'slides/latest' => 'latest_slides#index' # backward compatibility
  get 'popular' => 'popular_slides#index'
  get 'slides/popular' => 'popular_slides#index' # backward compatibility
  get 'page_count/:id' => 'slide_page_count#show'

  get 'player/:id' => 'player#show', as: :player
  get 'player/:id/:page' => 'player#show'
  get 'html_player/:id' => 'html_player#show'
  get 'slides/embedded/:id' => 'player#show'
  get 'slides/embedded/:id/:page' => 'player#show'
  get 'slides/:id/embedded' => 'player#show'
  get 'slides/:id/embedded/:page' => 'player#show'

  get 'download/:id' => 'slide_download#show'
  get 'slides/:id/download' => 'slide_download#show', as: :download_slide
  get 'slides/download/:id' => 'slide_download#show'

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks', registrations: 'users/registrations' }
  resources :slides do
    get 'index', on: :collection
  end
  get 'slides/view/:id' => 'slides#show'
  get 'slides/:id/:page' => 'slides#show'
  get 'users/view/:id' => 'users#show'
  get 'users/:id/embedded' => 'users#embedded'
  resources :users do
    get 'index', on: :collection
  end

  resources :comments, only: [:create, :destroy]

  resources :categories, only: [:show]

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
    resources :dashboards do
      get 'index', on: :collection
    end

    resources :featured_slides, only: [:index, :new, :create, :destroy]

    resources :slides do
      get 'index', on: :collection
      get 'edit', on: :collection
      post 'update', on: :collection
    end
    get 'slides/:id/download' => 'slides#download', as: :download_slide

    resources :users, only: [:index, :edit, :update, :destroy]

    resources :custom_contents do
      get 'index', on: :collection
      post 'update', on: :collection, as: :update
    end

    resources :site_settings do
      get 'index', on: :collection
      post 'update', on: :collection, as: :update
    end

    get 'custom_files/index' => 'custom_files#index'
    resources :custom_files, only: [:index, :new, :create, :destroy]

    get 'logs/index' => 'logs#index'
    get 'logs/show' => 'logs#show'
    get 'logs/download' => 'logs#download', as: :logs_download

    get 'pages/index' => 'pages#index'
    resources :pages, only: [:index, :new, :create, :edit, :update, :destroy]
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
