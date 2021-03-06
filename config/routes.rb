# encoding: utf-8
Deliverit::Application.routes.draw do
  devise_for :users
  scope "/admin" do
    resources :users
  end

  resources :shares

  root :to => "shares#index", :type => 'images'

  match '/content-type/:type' => 'shares#index', via: [:get]

  match '/download/:filename.:extension' => 'shares#download', :as => :share_download, via: [:get]
  match '/download/:version/:filename.:extension' => 'shares#download', :as => :share_version_download, via: [:get]

  match '/localupload/' => 'shares#upload_from_local', :as => :upload_from_local, via: [:get]
  match '/newtoken/' => 'users#generate_token', :as => :generate_token, via: [:put]
  get '/f/:user_id/:original_filename.:extension' => 'shares#show_by_name', constraints: { original_filename: /[^\/]+/ }

  get 'tags/:tag', to: 'shares#index', as: :tag

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :shares
    end
  end



  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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
