require 'test_helper'
require 'nokogiri'

class LocationsControllerTest < ActionDispatch::IntegrationTest

  test "get list of items in locations" do

    get '/shelf_item_matching.json/*'
    assert_response :success
    z = JSON.parse(response.body)
    assert z.length == 3, "Expected 3, got #{z.length}"

    get '/shelf_item_matching.json/*0'
    assert_response :success
    z = JSON.parse(response.body)
    assert z.length == 0

    get '/shelf_item_matching.json/*1'
    assert_response :success
    z = JSON.parse(response.body)
    assert z.length == 1

    get '/shelf_item_matching.json/*2'
    assert_response :success
    z = JSON.parse(response.body)
    assert z.length == 2, "Expected 2, got #{z.length}"

    get '/shelf_item_matching.json/*3'
    assert_response :success
    z = JSON.parse(response.body)
    assert z.length == 0

  end

  test "cancel request for locations" do
    get "/display_shelf_items", params:
      { commit: 'Cancel' }
    assert_redirected_to "/display_find_shelf_items_screen"
    assert flash[:notice] == "Operation Cancelled"
  end

  test "request for items by location" do
    get "/display_shelf_items", params:
      { commit: 'Submit', location_string: "Shelf *" }
    assert_response :success
    assert response.body =~ /data-url='shelf_item_matching.json\/Shelf%20\*'/
  end


  test "display_manage_location_request_screen" do
    get "/display_manage_location_request_screen"  #no parms
    assert_response :success
    html_doc = Nokogiri::HTML(response.body)
    assert_nil html_doc.at_css('input#location_string_id')['value']


    get "/display_manage_location_request_screen/Shelf%201"
    assert_response :success
    html_doc = Nokogiri::HTML(response.body)
    assert html_doc.at_css('input#location_string_id')['value'] == "Shelf 1"

    get "/display_manage_location_request_screen", params:
      { 'location_string_from_url': 'Shelf 2' }
    assert_response :success
    html_doc = Nokogiri::HTML(response.body)
    assert html_doc.at_css('input#location_string_id')['value'] == "Shelf 2"

    get "/display_manage_location_request_screen", params:
      { 'location_string_from_url': 'Shelf 3' }
    assert_redirected_to "/display_manage_location_request_screen"
    assert flash[:alert] == "Couldn't find Location"

  end

  test "manage location results- no side effects" do

    #
    # Cancel
    #

    get "/manage_location_result", params:
      { commit: 'Cancel' }
    assert_redirected_to "/display_manage_location_request_screen"
    assert flash[:notice] == "Operation Cancelled"

    #
    # Refresh
    #
    get "/manage_location_result", params:   #Refresh with no location
      { commit: 'Refresh' }
    assert_redirected_to "/display_manage_location_request_screen"

    #assert flash[:notice] == "Couldn't find Location"

    get "/manage_location_result", params:   #Refresh with valid location
      { commit: 'Refresh', location_string: "Shelf 1" }
    assert_redirected_to "/display_manage_location_request_screen/Shelf 1"


    get "/manage_location_result", params:   #Refresh with invalid location
      { commit: 'Refresh', location_string: "Shelf 3" }
    assert_redirected_to "/display_manage_location_request_screen/Shelf 3"
    assert flash[:notice] == "Operation Cancelled" #FIXME should be alert: can't find

    #
    # List all locations
    #
    get "/manage_location_result", params:
      { commit: 'List All Locations' }
    assert_redirected_to "/display_location_catalog"

  end

  test "manage location results - create with good user ID" do

    assert Location.count == 2
    get "/set_session_name", params: { commit: "Submit", user_name: "TechA", user_password: "john" }
    assert_redirected_to "/display_find_skus_screen"
    assert flash[:notice] == "Welcome back, TechA"
    get "/manage_location_result", params:
      { commit: 'Create', location_string: "NEWLOC", comment_string: "NEWCOMMENT",
      is_retired_string: "T"}

    assert_redirected_to "/display_manage_location_request_screen/NEWLOC"
    assert flash[:notice] == "Created NEWLOC"
    assert Location.count == 3

  end

  test "manage location results - create with non-admin user ID" do

    assert Location.count == 2
    get "/set_session_name", params: { commit: "Submit", user_name: "TechB", user_password: "" }
    assert_redirected_to "/display_find_skus_screen"
    get "/manage_location_result", params:
      { commit: 'Create', location_string: "NEW_LOC", comment_string: "NEW_COMMENT",
      is_retired_string: "T"}
    assert_redirected_to "/display_manage_location_request_screen"
    assert flash[:alert] == "Validation failed: Only admin users may update this"
    assert Location.count == 2

  end

  test "manage location results - create with no user ID" do

    assert Location.count == 2
    get "/manage_location_result", params:
      { commit: 'Create', location_string: "NEW_LOC", comment_string: "NEW_COMMENT",
      is_retired_string: "T" }
    assert_redirected_to "/display_manage_location_request_screen"
    assert flash[:alert] == "Validation failed: Only admin users may update this"
    assert Location.count == 2

  end

  test "manage location results - update with good user ID" do

    assert Location.count == 2
    get "/set_session_name", params: { commit: "Submit", user_name: "TechA", user_password: "john" }
    assert_redirected_to "/display_find_skus_screen"
    assert flash[:notice] == "Welcome back, TechA"
    get "/manage_location_result", params:
      { commit: 'Update', location_string: "Shelf 1", comment_string: "updated",
      is_retired_string: "T"}

    assert_redirected_to "/display_manage_location_request_screen/Shelf 1"
    assert flash[:notice] == "Updated Shelf 1"
    assert Location.count == 2
    assert Location.find_by(name: "Shelf 1").comment == "updated"

  end

  test "manage location results - update with non-admin user ID" do

    assert Location.count == 2
    get "/set_session_name", params: { commit: "Submit", user_name: "TechB", user_password: "" }
    assert_redirected_to "/display_find_skus_screen"
    get "/manage_location_result", params:
      { commit: 'Update', location_string: "Shelf 1", comment_string: "updated",
      is_retired_string: "T"}
    assert_redirected_to "/display_manage_location_request_screen"
    assert flash[:alert] == "Validation failed: Only admin users may update this"
    assert Location.count == 2
    assert Location.find_by(name: "Shelf 1").comment != "updated"

  end

  test "manage location results - update with no user ID" do

    assert Location.count == 2
    get "/manage_location_result", params:
      { commit: 'Update', location_string: "Shelf 1", comment_string: "updated",
      is_retired_string: "T" }
    assert_redirected_to "/display_manage_location_request_screen"
    assert flash[:alert] == "Validation failed: Only admin users may update this"
    assert Location.count == 2
    assert Location.find_by(name: "Shelf 1").comment != "updated"

  end

  test "manage location results - Delete with good user ID" do

    assert Location.count == 2
    get "/set_session_name", params: { commit: "Submit", user_name: "TechA", user_password: "john" }
    assert_redirected_to "/display_find_skus_screen"
    assert flash[:notice] == "Welcome back, TechA"
    get "/manage_location_result", params:
      { commit: 'Delete', location_string: "Shelf 1", comment_string: "updated",
      is_retired_string: "T"}

    assert_redirected_to "/display_manage_location_request_screen/Shelf 1"
    assert flash[:alert] == "Cannot delete location Shelf 1 since there is inventory in it or a transaction record"
    assert Location.count == 2

    # now create one and delete it
    get "/manage_location_result", params:
      { commit: 'Create', location_string: "NEWLOC", comment_string: "NEWCOMMENT",
      is_retired_string: "T"}

    assert_redirected_to "/display_manage_location_request_screen/NEWLOC"
    assert flash[:notice] == "Created NEWLOC"
    assert Location.count == 3

    get "/manage_location_result", params:
      { commit: 'Delete', location_string: "NEWLOC", comment_string: "updated",
      is_retired_string: "T"}

    assert_redirected_to "/display_manage_location_request_screen"
    assert flash[:notice] == "Deleted NEWLOC"
    assert Location.count == 2

  end

  test "manage location results - Delete with non-admin user ID" do

    assert Location.count == 2
    get "/set_session_name", params: { commit: "Submit", user_name: "TechB", user_password: "" }
    assert_redirected_to "/display_find_skus_screen"
    get "/manage_location_result", params:
      { commit: 'Delete', location_string: "Shelf 1", comment_string: "updated",
      is_retired_string: "T"}
    assert_redirected_to "/display_manage_location_request_screen/Shelf 1"
    assert flash[:alert] == "Cannot delete location Shelf 1 since there is inventory in it or a transaction record"
    assert Location.count == 2

  end

  test "manage location results - Delete with no user ID" do

    assert Location.count == 2
    get "/manage_location_result", params:
      { commit: 'Delete', location_string: "Shelf 1", comment_string: "updated",
      is_retired_string: "T" }
    assert_redirected_to "/display_manage_location_request_screen/Shelf 1"
    assert flash[:alert] == "Cannot delete location Shelf 1 since there is inventory in it or a transaction record"
    assert Location.count == 2

  end

  test "manage location results - attempt to delete non-existing location with good user ID" do

    assert Location.count == 2
    get "/set_session_name", params: { commit: "Submit", user_name: "TechA", user_password: "john" }
    assert_redirected_to "/display_find_skus_screen"
    assert flash[:notice] == "Welcome back, TechA"


    # now try to delete non-existing


    get "/manage_location_result", params:
      { commit: 'Delete', location_string: "UnknownLOC", comment_string: "updated",
      is_retired_string: "T"}

    assert_redirected_to "/display_manage_location_request_screen"
    assert flash[:alert] == "Couldn't find Location"
    assert Location.count == 2

  end


  test "get all locations as json" do

    get "/all_locations_as_json.json"

    assert_response :success
    assert response.content_type == "application/json"

    assert JSON.parse(response.body)[0]['loc'] == "Shelf 1"
    assert JSON.parse(response.body)[1]['comment'] == "Comment for location Shelf 2"

  end



end
