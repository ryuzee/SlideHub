Rails.application.routes.draw do
  get 'search' => 'search#index'
  get 'latest' => 'latest_slides#index'
  get 'slides/latest' => 'latest_slides#index' # backward compatibility
  get 'popular' => 'popular_slides#index'
  get 'slides/popular' => 'popular_slides#index' # backward compatibility

  devise_for :users
  resources :slides do
    get 'index', on: :collection
  end
  get 'slides/view/:id' => 'slides#show'
  get 'slides/download/:id' => 'slides#download'
  get 'slides/embedded/:id' => 'slides#embedded'
  get 'slides/embedded/:id/:page' => 'slides#embedded'
  get 'slides/:id/update_view' => 'slides#update_view'
  get 'slides/:id/embedded' => 'slides#embedded'
  get 'slides/:id/embedded/:page' => 'slides#embedded'
  get 'slides/:id/download' => 'slides#download'
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
  end

  # config/routes.rb
  Rails.application.routes.draw do
    root 'slides#index'
  end
end
