SAPI::Application.routes.draw do
  namespace :api do
    resources :terms, :only => [:index]
    resources :sources, :only => [:index]
    resources :purposes, :only => [:index]
    resources :units, :only => [:index]
    resources :languages, :only => [:index]
    resources :users, :only => [:index]
    resources :designations, :only => [:index]
    resources :species_listings, :only => [:index]
    resources :change_types, :only => [:index]
    resources :ranks, :only => [:index]
  end
  namespace :admin do
    resources :terms, :only => [:index, :create, :update, :destroy]
    resources :sources, :only => [:index, :create, :update, :destroy]
    resources :purposes, :only => [:index, :create, :update, :destroy]
    resources :units, :only => [:index, :create, :update, :destroy]
    resources :languages, :only => [:index, :create, :update, :destroy]
    resources :users, :only => [:index, :create, :update, :destroy]
    resources :designations, :only => [:index, :create, :update, :destroy]
    resources :species_listings, :only => [:index, :create, :update, :destroy]
    resources :change_types, :only => [:index, :create, :update, :destroy]
    resources :ranks, :only => [:index, :create, :update, :destroy]
    root :to => 'home#index'
  end

  match 'taxon_concepts/' => 'taxon_concepts#index'
  match 'taxon_concepts/autocomplete' => 'taxon_concepts#autocomplete'
  match 'taxon_concepts/summarise_filters' => 'taxon_concepts#summarise_filters'
  match 'download_index' => 'taxon_concepts#download_index'
  match 'download_history' => 'taxon_concepts#download_history'
  match 'geo_entities/:geo_entity_type' => 'geo_entities#index',
    :constraints => {:geo_entity_type => /#{GeoEntityType::COUNTRY}|#{GeoEntityType::CITES_REGION}/}
  match 'species_listings/:designation' => 'species_listings#index',
    :constraints => {:designation => /#{Designation::CITES}/}
  match 'timelines' => 'timelines#index'

  match 'downloads/index'   => 'downloads#download_index'
  match 'downloads/history' => 'downloads#download_history'

  resources :downloads do
    member do
      get :download
    end
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
