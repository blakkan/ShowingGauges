Rails.application.routes.draw do

  root 'dashboard#display_dashboard'

  get 'display_dashboard' => 'dashboard#display_dashboard'
  get 'display_advanced_search_screen' => 'dashboard#display_advanced_search_screen'
  get 'display_reorder_table' => 'dashboard#display_reorder_table'
  get 'data(.:format)' => 'dashboard#data'

  get 'third_party_auth' => 'login#third_party_auth'
  post 'third_party_auth' => 'login#third_party_auth'

  get 'display_login_screen' => 'login#display_login_screen'

  get 'set_session_name/:user_name' => 'login#set_session_name'
  get 'set_session_name' => 'login#set_session_name'

  get 'display_change_password_screen' => 'login#display_change_password_screen'
  get 'change_password_result' => 'login#change_password_result'

  get 'display_manage_user_request_screen/:user_string_from_url' => 'users#display_manage_user_request_screen'
  get 'display_manage_user_request_screen' => 'users#display_manage_user_request_screen'
  get 'manage_user_result' => 'users#manage_user_result'
  get 'display_user_catalog' => 'users#display_user_catalog'
  get 'all_users_as_json.json' => 'users#all_users_as_json'

  get 'display_find_skus_screen' => 'skus#display_find_skus_screen'
  get 'display_skus' => 'skus#display_skus'
  get 'display_sku_catalog' => 'skus#display_sku_catalog'
  get 'all_skus_as_json.json' => 'skus#all_skus_as_json'
  get 'display_manage_sku_request_screen/:sku_string' => 'skus#display_manage_sku_request_screen'
  get 'display_manage_sku_request_screen' => 'skus#display_manage_sku_request_screen'
  get 'manage_sku_result' => 'skus#manage_sku_result'
  get 'sku_found.json' => 'skus#sku_found'
  get 'sku_matching.json/:match_string' => 'skus#sku_matching'

  get 'display_bulk_import_request_screen' => 'skus#display_bulk_import_request_screen'
  post 'bulk_import_result' => 'skus#bulk_import_result'

  get 'display_find_shelf_items_screen' => 'locations#display_find_shelf_items_screen'
  get 'display_shelf_items' => 'locations#display_shelf_items'

  get 'display_manage_location_request_screen' => 'locations#display_manage_location_request_screen'
  get 'display_manage_location_request_screen/:location_string_from_url' => 'locations#display_manage_location_request_screen'
  get 'manage_location_result' => 'locations#manage_location_result'
  get 'shelf_item_matching.json/:match_string' => 'locations#shelf_item_matching'
  get 'display_location_catalog' => 'locations#display_location_catalog'
  get 'all_locations_as_json.json' => 'locations#all_locations_as_json'

  # Display transfer requests and results (qoh is quantity on hand; qtm is quantity to move)
  get 'display_transfer_request_screen(/:sku/:from/:qtm/(:to)/(:comment))' => 'bins#display_transfer_request_screen'
  get 'display_transfer_result(/:sku/:from/:qtm/:to/:comment)' => 'bins#display_transfer_result'

  #get 'display_transfer_in_request_screen' => 'bins#display_transfer_in_request_screen'
  #TODO change to post
  #get 'display_transfer_in_result' => 'bins#display_transfer_in_result'

  #get 'display_transfer_out_request_screen' => 'bins#display_transfer_out_request_screen'
  #TODO change to post
  #get 'display_transfer_out_result' => 'bins#display_transfer_out_result'

  get 'display_new_sku_request_screen' => 'bins#display_new_sku_request_screen'
  get 'display_new_sku_result' => 'bins#display_new_sku_result'


  get 'display_transactions_request_screen' => 'transactions#display_transactions_request_screen'
  get 'display_all_transactions' => 'transactions#display_all_transactions'
  get 'transactions_found(.:spud)/:start_date_name/:end_date_name' => 'transactions#transactions_found'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
