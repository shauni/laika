ActionController::Routing::Routes.draw do |map|
  map.resources :message_logs
  map.resources :atna_audits
  map.resources :vendors
  map.resources :users
  map.resources :document_locations
  map.resources :news, :singular => 'news_item'

  # test operations on vendor test plans
  map.testop '/vendor_test_plans/:vendor_test_plan_id/testop/:test_type/:test_operation',
    :controller => 'testop', :action => 'perform_test_operation'

  map.resources :vendor_test_plans, :member => {:validate => :get,
                                                :checklist => :get,
                                                :set_status => :get }

  map.resources :patients,
      :has_one  => [:registration_information, :support, :information_source, :advance_directive, :pregnancy],
      :has_many => [:languages, :providers, :insurance_providers, 
                    :insurance_provider_patients, :insurance_provider_subscribers, 
                    :insurance_provider_guarantors, :medications, :allergies, :conditions, 
                    :results, :immunizations, :vital_signs,
                    :encounters, :procedures, :medical_equipments, :patient_identifiers],
      :member   => {:set_no_known_allergies => :post, :edit_template_info => :get },
      :collection => { :autoCreate => :post }

  map.with_options :controller => 'xds_patients' do |xds_patients|
    xds_patients.xds_patients '/xds_patients', :action => 'index'
    xds_patients.query_xds_patient '/xds_patients/query/:id', :action => 'query'
    xds_patients.provide_and_register_setup_xds_patient '/xds_patients/provide_and_register_setup/:id', :action => 'provide_and_register_setup'
    xds_patients.provide_and_register_xds_patient '/xds_patients/provide_and_register/:id', :action => 'provide_and_register'
    xds_patients.do_provide_and_register_xds_patient '/xds_patients/do_provide_and_register', :action => 'do_provide_and_register'
  end

  map.with_options :controller => 'account' do |account|
    %w[ signup login logout forgot_password reset_password ].each do |action|
      account.send(action, "/account/#{action}", :action => action)
    end
  end

  # to support autocomplete actions, include each autocomplete-able controller/action in the list
  { 'conditions' => %w[ snowmed_problem_name ] }.each do |controller, actions|
    actions.each do |action|
      map.connect "/autocomplete/#{controller}/#{action}",
        :controller => controller, :action => "auto_complete_for_#{action}"
    end
  end

  map.root :controller => "vendor_test_plans"

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

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"
end
