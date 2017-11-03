require 'test_helper'
require 'nokogiri'

class UsersControllerTest < ActionDispatch::IntegrationTest

  test "display_manage_user_request_screen" do
    get "/display_manage_user_request_screen"  #no parms
    assert_response :success
    html_doc = Nokogiri::HTML(response.body)
    assert_nil html_doc.at_css('input#user_string_id')['value']


    get "/display_manage_user_request_screen/TechA"
    assert_response :success
    html_doc = Nokogiri::HTML(response.body)
    assert html_doc.at_css('input#user_string_id')['value'] == "TechA"

    get "/display_manage_user_request_screen", params:
      { 'user_string_from_url': 'TechB' }
    assert_response :success
    html_doc = Nokogiri::HTML(response.body)
    assert html_doc.at_css('input#user_string_id')['value'] == "TechB"

    get "/display_manage_user_request_screen", params:
      { 'user_string_from_url': 'Zippy' }
    #Should this thow an alert?
    assert_response :success
    html_doc = Nokogiri::HTML(response.body)
    refute html_doc.at_css('input#user_string_id').key?('value')

  end

  test "manage user results- no side effects" do

    #
    # Cancel
    #

    get "/manage_user_result", params:
      { commit: 'Cancel' }
    assert_redirected_to "/display_manage_user_request_screen"
    assert flash[:notice] == "Operation Cancelled"

    #
    # Refresh
    #
    get "/manage_user_result", params:   #Refresh with no user name
      { commit: 'Refresh' }
    assert_redirected_to "/display_manage_user_request_screen"


    get "/manage_user_result", params:   #Refresh with valid user
      { commit: 'Refresh', user_string: "TechA" }
    assert_redirected_to "/display_manage_user_request_screen/TechA"


    get "/manage_user_result", params:   #Refresh with invalid user
      { commit: 'Refresh', user_string: "TechC" }
    assert_redirected_to "/display_manage_user_request_screen/TechC"
    assert flash[:notice] == "Operation Cancelled" #FIXME should be alert: can't find

    #
    # List all locations
    #
    get "/manage_user_result", params:
      { commit: 'List All Users' }
    assert_redirected_to "/display_user_catalog"

  end

  test "manage user results - create with good user ID" do

    assert User.count == 2
    get "/set_session_name", params: { commit: "Submit", user_name: "TechA", user_password: "john" }
    assert_redirected_to "/display_find_skus_screen"
    assert flash[:notice] == "Welcome back, TechA"
    get "/manage_user_result", params:
      { commit: 'Create', user_string: "NewUser", comment_string: "NEWCOMMENT",
      is_retired_string: "T", is_admin_string: "T" }

    assert_redirected_to "/display_manage_user_request_screen/NewUser"
    assert flash[:notice] == "Created NewUser"
    assert User.count == 3

  end

  test "manage user results - create with non-admin user ID" do

    assert User.count == 2
    get "/set_session_name", params: { commit: "Submit", user_name: "TechB", user_password: "" }
    assert_redirected_to "/display_find_skus_screen"
    assert flash[:notice] == "Welcome back, TechB"
    get "/manage_user_result", params:
      { commit: 'Create', user_string: "NewUser", comment_string: "NEWCOMMENT",
      is_retired_string: "T", is_admin_string: "T" }
    assert_redirected_to "/display_manage_user_request_screen"
    assert flash[:alert] == "Validation failed: Only admin users may update this"
    assert Location.count == 2

  end

  test "manage location results - create with no user ID" do

    assert User.count == 2
    get "/set_session_name", params: { commit: "Submit", user_name: "TechC", user_password: "" }
    get "/manage_user_result", params:
      { commit: 'Create', user_string: "NewUser", comment_string: "NEWCOMMENT",
      is_retired_string: "T", is_admin_string: "T" }
    assert_redirected_to "/display_manage_user_request_screen"
    assert flash[:alert] == "Validation failed: Only admin users may update this"
    assert User.count == 2

  end

  test "manage user results - update with good user ID" do

    assert Location.count == 2
    get "/set_session_name", params: { commit: "Submit", user_name: "TechA", user_password: "john" }
    assert_redirected_to "/display_find_skus_screen"
    assert flash[:notice] == "Welcome back, TechA"
    get "/manage_user_result", params:
      { commit: 'Update', user_string: "TechB", comment_string: "updated",
      is_retired_string: "T"}

    assert_redirected_to "/display_manage_user_request_screen/TechB"
    assert flash[:notice] == "Updated TechB"
    assert User.count == 2
    assert User.find_by(name: "TechB").comment == "updated"

  end

  test "manage user results - update with good user ID and reset password string" do

    assert Location.count == 2
    get "/set_session_name", params: { commit: "Submit", user_name: "TechA", user_password: "john" }
    assert_redirected_to "/display_find_skus_screen"
    assert flash[:notice] == "Welcome back, TechA"
    get "/manage_user_result", params:
      { commit: 'Update', user_string: "TechA", comment_string: "updated",
      is_retired_string: "T", reset_password_string: "T", is_admin_string: "Y"}
    assert_redirected_to "/display_manage_user_request_screen/TechA"
    assert flash[:notice] == "Updated TechA"
    assert User.count == 2
    assert User.find_by(name: "TechA").encrypted_password == ""


  end

  test "manage location results - update with non-admin user ID" do

    assert Location.count == 2
    get "/set_session_name", params: { commit: "Submit", user_name: "TechB", user_password: "" }
    assert_redirected_to "/display_find_skus_screen"
    assert flash[:notice] == "Welcome back, TechB"
    get "/manage_user_result", params:
      { commit: 'Update', user_string: "TechA", comment_string: "updated",
      is_retired_string: "T"}
    assert_redirected_to "/display_manage_user_request_screen"
    assert flash[:alert] == "Validation failed: Only admin users may update this"
    assert User.count == 2
    assert User.find_by(name: "TechA").comment != "updated"

  end

  test "manage user results - update with no user ID" do

    assert User.count == 2
    get "/manage_user_result", params:
      { commit: 'Update', user_string: "TechA", comment_string: "updated",
      is_retired_string: "T" }
    assert_redirected_to "/display_manage_user_request_screen"
    assert flash[:alert] == "Validation failed: Only admin users may update this"
    assert User.count == 2
    assert User.find_by(name: "TechA").comment != "updated"

  end


  #TODO Users currently don't support delete (Perhaps this should change, be like
  # Locations where a user which has never transacted and is associated with no bins
  # could be deleted (i.e. if there was a typo in creation)


  test "get all users as json" do

    get "/all_users_as_json.json"

    assert_response :success
    assert response.content_type == "application/json"
    assert JSON.parse(response.body)[0]['user'] == "TechA"
    assert JSON.parse(response.body)[1]['user'] == "TechB"

  end


end
