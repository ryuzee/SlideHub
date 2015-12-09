Rails.application.routes.draw do
  devise_for :users
  resources :slides do
    get 'index', on: :collection
    get 'latest', on: :collection
    get 'popular', on: :collection
    get 'search', on: :collection
  end
  get 'slides/category/:id' => 'slides#category'
  get 'slides/:id/update_view' => 'slides#update_view'
  get 'slides/:id/embedded' => 'slides#embedded'
  get 'slides/:id/download' => 'slides#download'
  get 'slides/view/:id' => 'slides#show'
  get 'slides/download/:id' => 'slides#download'
  get 'slides/embedded/:id' => 'slides#embedded'

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

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root to: 'welcome#index'

  # config/routes.rb
  Rails.application.routes.draw do
    root 'slides#index'
  end

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
