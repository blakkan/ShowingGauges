require 'test_helper'

class SkusControllerTest < ActionDispatch::IntegrationTest

  test "get list of skus" do

    get '/sku_matching.json/*'
    assert_response :success
    z = JSON.parse(response.body)
    assert z.length == 2

    get '/sku_matching.json/*0'
    assert_response :success
    z = JSON.parse(response.body)
    assert z.length == 1

    get '/sku_matching.json/*1'
    assert_response :success
    z = JSON.parse(response.body)
    assert z.length == 1

    get '/sku_matching.json/*3'
    assert_response :success
    z = JSON.parse(response.body)
    assert z.length == 0

  end


  test "cancel request for skus" do
    get "/display_skus", params:
      { commit: 'Cancel' }
    assert_redirected_to "/display_find_skus_screen"
    assert flash[:notice] == "Operation Cancelled"
  end


  test "request for skus matching pattern" do
    get "/display_skus", params:
      { commit: 'Submit', sku_string: "80-*" }
    assert_response :success
    assert response.body =~ /data-url='sku_matching.json\/80-\*'/
  end


  test "display_manage_sku_request_screen should be blank" do
    get "/display_manage_sku_request_screen"  #no parms
    assert_response :success
    html_doc = Nokogiri::HTML(response.body)
    assert_nil html_doc.at_css('input#sku_string_id')['value']


    get "/display_manage_sku_request_screen/80-000000"
    assert_response :success
    html_doc = Nokogiri::HTML(response.body)
    assert html_doc.at_css('input#sku_string_id')['value'] == "80-000000"

    get "/display_manage_sku_request_screen", params:
      { sku_string: '80-000000' }
    assert_response :success
    html_doc = Nokogiri::HTML(response.body)
    assert html_doc.at_css('input#sku_string_id')['value'] == "80-000000"

    get "/display_manage_sku_request_screen", params:
      { sku_string: '99A' }
    assert_response :success
    html_doc = Nokogiri::HTML(response.body)
    assert_nil html_doc.at_css('input#sku_string_id')['value']

  end

  test "manage sku results- no side effects" do

    #
    # Cancel
    #

    get "/manage_sku_result", params:
      { commit: 'Cancel' }
    assert_redirected_to "/display_manage_sku_request_screen"
    assert flash[:notice] == "Operation Cancelled"

    #
    # Refresh
    #
    get "/manage_sku_result", params:   #Refresh with no sku number
      { commit: 'Refresh' }
    assert_redirected_to "/display_manage_sku_request_screen"

    #assert flash[:notice] == "Couldn't find sku"

    get "/manage_sku_result", params:   #Refresh with valid sku number
      { commit: 'Refresh', sku_string: "80-000000" }
    assert_redirected_to "/display_manage_sku_request_screen/80-000000"


    get "/manage_sku_result", params:   #Refresh with invalid sku number
      { commit: 'Refresh', sku_string: "99" }
    assert_redirected_to "/display_manage_sku_request_screen/99"
    assert flash[:notice] == "Operation Cancelled" #FIXME should be alert: can't find

    #
    # List all skus
    #
    get "/manage_sku_result", params:
      { commit: 'List All SKU Types' }
    assert_redirected_to "/display_sku_catalog"

  end

  test "manage sku results - create with good user ID" do

    assert Sku.count == 2
    get "/set_session_name", params: { commit: "Submit", user_name: "TechA", user_password: "john" }
    assert_redirected_to "/display_find_skus_screen"
    assert flash[:notice] == "Welcome back, TechA"
    get "/manage_sku_result", params:
      { commit: 'Create', sku_string: "NEWSKU", comment_string: "NEWCOMMENT",
      is_retired_string: "T"}

    assert_redirected_to "/display_manage_sku_request_screen/NEWSKU"
    assert flash[:notice] == "Created NEWSKU"
    assert Sku.count == 3

  end

  test "manage sku results - create with non-admin user ID" do

    assert Sku.count == 2
    get "/set_session_name", params: { commit: "Submit", user_name: "TechB", user_password: "" }
    assert_redirected_to "/display_find_skus_screen"
    get "/manage_sku_result", params:
      { commit: 'Create', sku_string: "NEW_SKU", comment_string: "NEW_COMMENT",
      is_retired_string: "T"}
    assert_redirected_to "/display_manage_sku_request_screen"
    assert flash[:alert] == "Validation failed: Only admin users may update this"
    assert Sku.count == 2

  end

  test "manage sku results - create with no user ID" do

    assert Sku.count == 2
    get "/manage_sku_result", params:
      { commit: 'Create', sku_string: "NEW_SKU", comment_string: "NEW_COMMENT",
      is_retired_string: "T" }
    assert_redirected_to "/display_manage_sku_request_screen"
    assert flash[:alert] == "Validation failed: Only admin users may update this"
    assert Sku.count == 2

  end

  test "manage sku results - update with good user ID" do

    assert Sku.count == 2
    get "/set_session_name", params: { commit: "Submit", user_name: "TechA", user_password: "john" }
    assert_redirected_to "/display_find_skus_screen"
    assert flash[:notice] == "Welcome back, TechA"
    get "/manage_sku_result", params:
      { commit: 'Update', sku_string: "80-000000", comment_string: "updated",
      is_retired_string: "T"}

    assert_redirected_to "/display_manage_sku_request_screen/80-000000"
    assert flash[:notice] == "Updated 80-000000"
    assert Sku.count == 2
    assert Sku.find_by(name: "80-000000").comment == "updated"

  end

  test "manage sku results - update with non-admin user ID" do

    assert Sku.count == 2
    get "/set_session_name", params: { commit: "Submit", user_name: "TechB", user_password: "" }
    assert_redirected_to "/display_find_skus_screen"
    get "/manage_sku_result", params:
      { commit: 'Update', sku_string: "80-000000", comment_string: "updated",
      is_retired_string: "T"}
    assert_redirected_to "/display_manage_sku_request_screen"
    assert flash[:alert] == "Validation failed: Only admin users may update this"
    assert Sku.count == 2
    assert Sku.find_by(name: "80-000000").comment != "updated"

  end

  test "manage sku results - update with no user ID" do

    assert Sku.count == 2
    get "/manage_sku_result", params:
      { commit: 'Update', sku_string: "80-000000", comment_string: "updated",
      is_retired_string: "T" }
    assert_redirected_to "/display_manage_sku_request_screen"
    assert flash[:alert] == "Validation failed: Only admin users may update this"
    assert Sku.count == 2
    assert Sku.find_by(name: "80-000000").comment != "updated"

  end

  test "manage sku results - Delete with good user ID" do

    assert Sku.count == 2
    get "/set_session_name", params: { commit: "Submit", user_name: "TechA", user_password: "john" }
    assert_redirected_to "/display_find_skus_screen"
    assert flash[:notice] == "Welcome back, TechA"
    get "/manage_sku_result", params:
      { commit: 'Delete', sku_string: "80-000000", comment_string: "updated",
      is_retired_string: "T"}

    assert_redirected_to "/display_manage_sku_request_screen/80-000000"
    assert flash[:alert] == "Cannot delete sku type 80-000000 since there is inventory in some location or a transaction record"
    assert Sku.count == 2

    # now create one and delete it
    get "/manage_sku_result", params:
      { commit: 'Create', sku_string: "NEWSKU", comment_string: "NEWCOMMENT",
      is_retired_string: "T"}

    assert_redirected_to "/display_manage_sku_request_screen/NEWSKU"
    assert flash[:notice] == "Created NEWSKU"
    assert Sku.count == 3

    get "/manage_sku_result", params:
      { commit: 'Delete', sku_string: "NEWSKU", comment_string: "updated",
      is_retired_string: "T"}

    assert_redirected_to "/display_manage_sku_request_screen"
    assert flash[:notice] == "Deleted NEWSKU"
    assert Sku.count == 2

  end

  test "manage Sku results - Delete with non-admin user ID" do

    assert Sku.count == 2
    get "/set_session_name", params: { commit: "Submit", user_name: "TechB", user_password: "" }
    assert_redirected_to "/display_find_skus_screen"
    get "/manage_sku_result", params:
      { commit: 'Delete', sku_string: "80-000000", comment_string: "updated",
      is_retired_string: "T"}
    assert_redirected_to "/display_manage_sku_request_screen/80-000000"
    assert flash[:alert] == "Cannot delete sku type 80-000000 since there is inventory in some location or a transaction record"
    assert Sku.count == 2

  end

  test "manage sku results - Delete with no user ID" do

    assert Sku.count == 2
    get "/manage_sku_result", params:
      { commit: 'Delete', sku_string: "80-000000", comment_string: "updated",
      is_retired_string: "T" }
    assert_redirected_to "/display_manage_sku_request_screen/80-000000"
    assert flash[:alert] == "Cannot delete sku type 80-000000 since there is inventory in some location or a transaction record"
    assert Sku.count == 2

  end

  test "manage sku results - attempt to delete non-existing sku with good user ID" do

    assert Sku.count == 2
    get "/set_session_name", params: { commit: "Submit", user_name: "TechA", user_password: "john" }
    assert_redirected_to "/display_find_skus_screen"
    assert flash[:notice] == "Welcome back, TechA"


    # now try to delete non-existing


    get "/manage_sku_result", params:
      { commit: 'Delete', sku_string: "UnknownSKU", comment_string: "updated",
      is_retired_string: "T"}

    assert_redirected_to "/display_manage_sku_request_screen"
    assert flash[:alert] == "Couldn't find Sku"
    assert Sku.count == 2

  end


  test "get all skus as json" do

    get "/all_skus_as_json.json"

    assert_response :success
    assert response.content_type == "application/json"

    assert JSON.parse(response.body)[0]['sku_num'] == "80-000000"
    assert JSON.parse(response.body)[1]['category'] == "Cat2"

  end









end
