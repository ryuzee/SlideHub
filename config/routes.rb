Rails.application.routes.draw do
  get 'search' => 'search#index'
  get 'latest' => 'latest_slides#index'
  get 'slides/latest' => 'latest_slides#index' # backward compatibility
  get 'popular' => 'popular_slides#index'
  get 'slides/popular' => 'popular_slides#index' # backward compatibility
  get 'page_count/:id' => 'slide_page_count#show'

  get 'player/:id' => 'player#show'
  get 'player/:id/:page' => 'player#show'
  get 'html_player/:id' => 'html_player#show'
  get 'slides/embedded/:id' => 'player#show'
  get 'slides/embedded/:id/:page' => 'player#show'
  get 'slides/:id/embedded' => 'player#show'
  get 'slides/:id/embedded/:page' => 'player#show'

  get 'download/:id' => 'slide_download#show'
  get 'slides/:id/download' => 'slide_download#show'
  get 'slides/download/:id' => 'slide_download#show'

  devise_for :users
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

  get ':username' => 'users#show'
  get ':username/statistics' => 'users#statistics'
  get ':username/embedded' => 'users#embedded'

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
    get 'slides/:id/download' => 'slides#download'

    resources :users, only: [:index]
    resources :custom_contents do
      get 'index', on: :collection
      post 'update', on: :collection
    end
    resources :site_settings do
      get 'index', on: :collection
      post 'update', on: :collection
    end

    get 'logs/index' => 'logs#index'
    get 'logs/show' => 'logs#show'

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
