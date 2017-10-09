Rails.application.routes.draw do

  root 'login#display_login_screen'

  resources :transactions
  resources :skus
  resources :locations
  resources :users

  get 'display_login_screen' => 'login#display_login_screen'
  get 'display_find_sku_screen' => 'controller#method'
  get 'display_shelf_list_screen' => 'controller#method'
  get 'display_transfer_screen' => 'controller#method'
  get 'display_transfer_in_screen' => 'controller#method'
  get 'display_transfer_out_screen' => 'controller#method'

  get 'set_session_name/:user_name' => 'login#set_session_name'
  get 'set_session_name' => 'login#set_session_name'

  get 'display_manage_user_request_screen' => 'users#display_manage_user_request_screen'
  get 'manage_user_result' => 'users#manage_user_result'


  get 'display_find_skus_screen' => 'skus#display_find_skus_screen'
  get 'display_skus' => 'skus#display_skus'
  get 'display_manage_sku_request_screen' => 'skus#display_manage_sku_request_screen'
  get 'manage_sku_result' => 'skus#manage_sku_result'
  get 'sku_found.json' => 'skus#sku_found'



  get 'display_find_shelf_items_screen' => 'locations#display_find_shelf_items_screen'
  get 'display_shelf_items' => 'locations#display_shelf_items'
  get 'display_manage_location_request_screen' => 'locations#display_manage_location_request_screen'
  get 'manage_location_result' => 'locations#manage_location_result'
  get 'shelf_item_found.json' => 'locations#shelf_item_found'


  get 'display_transfer_request_screen' => 'bins#display_transfer_request_screen'
  #TODO change to post
  get 'display_transfer_result' => 'bins#display_transfer_result'

  get 'display_transfer_in_request_screen' => 'bins#display_transfer_in_request_screen'
  #TODO change to post
  get 'display_transfer_in_result' => 'bins#display_transfer_in_result'

  get 'display_transfer_out_request_screen' => 'bins#display_transfer_out_request_screen'
  #TODO change to post
  get 'display_transfer_out_result' => 'bins#display_transfer_out_result'

  get 'display_all_transactions' => 'transactions#display_all_transactions'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
