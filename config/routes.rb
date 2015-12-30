Rails.application.routes.draw do
  devise_for :users
  resources :slides do
    get 'index', on: :collection
    get 'latest', on: :collection
    get 'popular', on: :collection
    get 'search', on: :collection
  end
  get 'slides/view/:id' => 'slides#show'
  get 'slides/download/:id' => 'slides#download'
  get 'slides/embedded/:id' => 'slides#embedded'
  get 'slides/embedded/:id/:page' => 'slides#embedded'
  get 'slides/embedded_v2/:id' => 'slides#embedded_v2'
  get 'slides/category/:id' => 'slides#category'
  get 'slides/:id/update_view' => 'slides#update_view'
  get 'slides/:id/embedded' => 'slides#embedded'
  get 'slides/:id/embedded/:page' => 'slides#embedded'
  get 'slides/:id/embedded_v2' => 'slides#embedded_v2'
  get 'slides/:id/download' => 'slides#download'
  get 'slides/:id/:page' => 'slides#show'

  get 'users/view/:id' => 'users#show'
  resources :users do
    get 'index', on: :collection
    get 'statistics', on: :collection
  end
  resources :slides
  resources :comments, only: [:create, :destroy]

  resources :managements do
    get 'dashboard', on: :collection
    get 'user_list', on: :collection
    get 'slide_list', on: :collection
    get 'popular', on: :collection
    get 'search', on: :collection
    get 'custom_contents_setting', on: :collection
    post 'custom_contents_update', on: :collection
    get 'site_setting', on: :collection
    post 'site_update', on: :collection
  end
  get 'managements/slide_edit/:id' => 'managements#slide_edit'
  post 'managements/slide_update' => 'managements#slide_update'

  # config/routes.rb
  Rails.application.routes.draw do
    root 'slides#index'
  end
end
