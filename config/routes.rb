Foodholic::Application.routes.draw do

  devise_for :users
  devise_for :user
  
  get '/search' => 'recipes#search' , :via => :get, :as => 'search_recipes'
  get '/search' => 'recipes#search_recipes', :via => :post
  get '/recipes/:id/:ratings/rated_users' => 'recipes#rated_users_list', :as => 'rated_users_list' 

  get '/recipes/top_rated_recipes' => 'recipes#top_rated_recipes', :as => "top_rated_recipes"
  get '/recipes/most_rated_recipes'=> 'recipes#most_rated_recipes', :as => "most_rated_recipes"
  get '/recipes/pending' => 'recipes#admin_pending_recipes', :as => 'admin_pending_recipes' 
  
  # match '/login' => 'sessions#create', :via => :post
  # match '/login' => 'sessions#login'
  match '/logout' => 'sessions#destroy', :via => :delete
  # match '/signup' => 'users#new'
  root :to => 'home#index' 
  # match '/users' => 'users#create', :via => :post  

  # User::Application.routes.draw do 
  #   resources :users
  #   root :to => 'home#index' 
  # end


  
  scope :module => "user"   do
    match '/recipes/new' => 'user_recipes#new', :via => :get, :as => 'new_recipe'   
    match '/recipes/rate' => 'user_recipes#rate_recipe', :via => :post
    get '/recipes/:id/edit' => 'user_recipes#edit' , :as => 'edit_recipe'
    put '/recipes/:id' => 'user_recipes#update'
    post '/recipes' => 'user_recipes#create'
    get '/recipes/my_pending_recipes' => 'user_recipes#my_pending_recipes', :as => "my_pending_recipes"
    get '/recipes/my_rejected_recipes' => 'user_recipes#my_rejected_recipes', :as => "my_rejected_recipes"
    get '/recipes/my_top_rated_recipes' => 'user_recipes#my_top_rated_recipes', :as => "my_top_rated_recipes"
    get '/recipes/my_most_rated_recipes' => 'user_recipes#my_most_rated_recipes', :as => "my_most_rated_recipes"
    get '/recipes/my_approved_recipes' => 'user_recipes#my_approved_recipes', :as => "my_approved_recipes"
  end
  
  scope :module => "admin" do
    match '/recipes/approve_recipe' => 'admin_recipes#approve_recipe' , :via => :put
    match '/recipes/reject_recipe' => 'admin_recipes#reject_recipe', :via => :put
  end
  get '/recipes/:id' => 'recipes#show' ,:as => 'recipe'
  
  # resources :users
  # resources :ratings




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

  # You can have the root of your site routed with 'root'
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with 'rake routes'

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
