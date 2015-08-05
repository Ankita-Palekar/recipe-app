Foodholic::Application.routes.draw do

  devise_for :users
  root :to => 'home#index' 
  # devise_for :users, controllers: { sessions: "users/sessions" }

  match '/search' => 'recipes#search' , :via => :get
  devise_for :user
  match '/search' => 'recipes#searchrecipes', :via => :post
  match '/recipes/:id/:ratings/rated_users' => 'recipes#rated_users_list',:via => :get
  match '/recipes/top_rated_recipes' => 'recipes#top_rated_recipes' 
  match '/recipes/most_rated_recipes'=> 'recipes#most_rated_recipes' 
  match '/recipes/pending' => 'recipes#admin_pending_recipes' 
    
  # match '/'   =>  'home#index' 
  root to: "home#index"
  # match '/login' => 'sessions#create', :via => :post
  # match '/login' => 'sessions#login'
  match '/logout' => 'sessions#destroy', :via => :delete
  # match '/signup' => 'users#new'
  # match '/users' => 'users#create', :via => :post  

  # User::Application.routes.draw do 
  #   resources :users
  #   root :to => 'home#index' 
  # end


  
  scope :module => "user"   do
    match '/recipes/new' => 'user_recipes#new', :via => :get    
    match '/recipes/rate' => 'user_recipes#rate_recipe', :via => :post
    match '/recipes/edit/:id' => 'user_recipes#edit', :via => :get #@@TODO change route to /controller/:id/edit
    match '/recipes/edit/:id' => 'user_recipes#update', :via => :post
    match '/recipes' => 'user_recipes#create', :via => :post
    match '/recipes/my_pending_recipes' => 'user_recipes#my_pending_recipes', :via => :get
    match '/recipes/my_rejected_recipes' => 'user_recipes#my_rejected_recipes', :via => :get
    match '/recipes/my_top_rated_recipes' => 'user_recipes#my_top_rated_recipes', :via => :get
    match '/recipes/my_most_rated_recipes' => 'user_recipes#my_most_rated_recipes', :via => :get
    match '/recipes/my_approved_recipes' => 'user_recipes#my_approved_recipes', :via => :get
  end
  
  scope :module => "admin" do
    match '/recipes/approve_recipe' => 'admin_recipes#approve_recipe' , :via => :put
    match '/recipes/reject_recipe' => 'admin_recipes#reject_recipe', :via => :put
  end

  match '/recipes/:id' => 'recipes#show' ,:via => :get

  resources :users
  
  
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
