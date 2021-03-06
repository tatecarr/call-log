ActionController::Routing::Routes.draw do |map|

  #map.resources :house_staffs
  map.resources :houses, :has_many => :house_staffs
  
  map.resources :house_staffs

  map.resources :staffs, :as => "call-log"
  
  map.resources :feedbacks

  map.logout 'logout', :controller => 'sessions', :action => 'destroy'
  map.login 'login', :controller => 'sessions', :action => 'new'
  map.home 'home', :controller => 'sessions', :action => 'home'
  map.change_password 'change-password', :controller => "users", :action => "password_reset"
  
  map.email_feedback 'email_feedback', :controller => "feedback", :action => "index"
  map.user_manual 'user_manual', :controller => 'sessions', :action => 'get_user_manual'
  
  map.non_res_staff 'non-res-staff', :controller => "admin", :action => "agency_staff"
  map.backup_restore 'backup-restore', :controller => "admin", :action => "backup_restore" 
  map.import_staff 'import-staff', :controller => "admin", :action => "import_staff" 
  map.edit_session_timeout 'edit-session-timeout', :controller => "admin", :action => "edit_session_timeout" 
  
  map.root :controller => 'sessions', :action => "new" 
  map.resources :sessions
  map.resources :admin

  map.resources :users
  
  map.resources :reports

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
