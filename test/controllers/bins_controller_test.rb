require 'test_helper'

class BinsControllerTest < ActionDispatch::IntegrationTest


  test "display transfer request screen with sku, loc, and qty" do
    get "/set_session_name", params: {commit: "Submit", user_name: "TechA", user_password: "john"}

    get "/display_transfer_request_screen/80-000000/Shelf%201/8"
    #p response.body
    assert_response :success
    html_doc = Nokogiri::HTML(response.body)
    assert html_doc.at_css('h2').text().strip == "Transfer request:"
    assert html_doc.at_css('h3').text().strip == "SKU"
    assert html_doc.at_css('input#sku_id')['value']  == "80-000000"
    assert html_doc.at_css('input#from_id')['value'] == "Shelf 1"
    assert html_doc.at_css('input#qty_id')['value'] == "8"
  end

  test "display transfer request screen without  sku, loc, or qty" do
    get "/set_session_name", params: {commit: "Submit", user_name: "TechA", user_password: "john"}

    get "/display_transfer_request_screen"
    #p response.body
    assert_response :success
    html_doc = Nokogiri::HTML(response.body)
    assert html_doc.at_css('h2').text().strip == "Transfer request:"
    assert html_doc.at_css('h3').text().strip == "SKU"
    assert_nil html_doc.at_css('input#sku_id')['value']
    assert_nil  html_doc.at_css('input#from_id')['value']
    assert_nil  html_doc.at_css('input#qty_id')['value']
  end

  test "display transfer result with cancel without comment" do
    get "/set_session_name", params: {commit: "Submit", user_name: "TechA", user_password: "john"}
    get "/display_transfer_result", params:
      { commit: 'Cancel', sku: "80-123456", from: "Shelf 1", to: "Shelf 2", quantity: "0" }
    assert_redirected_to "/display_transfer_request_screen/80-123456/Shelf%201/0/Shelf%202"
    assert flash[:notice] == "Action Cancelled"
  end

  test "display transfer result with cancel with comment" do
    get "/set_session_name", params: {commit: "Submit", user_name: "TechA", user_password: "john"}
    get "/display_transfer_result", params:
      { commit: 'Cancel', sku: "80-123456", from: "Shelf 1", to: "Shelf 2", quantity: "0", comment: ""  }
    assert_redirected_to "/display_transfer_request_screen/80-123456/Shelf%201/0/Shelf%202/"
    assert flash[:notice] == "Action Cancelled"
  end

  #
  # Add to stock
  #
  test "display transfer result with add non-existing sku to stock" do
    get "/set_session_name", params: {commit: "Submit", user_name: "TechA", user_password: "john"}
    get "/display_transfer_result", params:
      { commit: 'Add to Stock', sku: "80-000004",  to: "Shelf 1", quantity: "3"  }
    assert_redirected_to "/display_transfer_request_screen/80-000004/Shelf%201/0"

    assert flash[:alert] == "Couldn't find Sku"
  end

  test "display transfer result without source/dest" do
    get "/set_session_name", params: {commit: "Submit", user_name: "TechA", user_password: "john"}
    get "/display_transfer_result", params:
      { commit: 'Add to Stock', sku: "80-000004", quantity: "3"  }
    assert_redirected_to "/display_transfer_request_screen"
    assert flash[:alert] == "Must have a \"To Location \" to transfer new items into."
  end

  test "display transfer result with add existing sku to stock" do
    get "/set_session_name", params: {commit: "Submit", user_name: "TechA", user_password: "john"}
    old_count = Bin.find_by(sku_id: 1, location_id: 1).qty
    get "/display_transfer_result", params:
      { commit: 'Add to Stock', sku: "80-000000",  to: "Shelf 1", quantity: "3"  }
    assert_redirected_to "/display_transfer_request_screen/80-000000/Shelf%201/#{(old_count + 3).to_s}"
    assert flash[:notice] == "Success"
    assert Bin.find_by(sku_id: 1, location_id: 1).qty = old_count + 3
  end

  test "display transfer result with add existing sku to stock and creating bin" do
    get "/set_session_name", params: {commit: "Submit", user_name: "TechA", user_password: "john"}
    assert Bin.find_by(sku_id: 2, location_id: 1).nil?
    get "/display_transfer_result", params:
      { commit: 'Add to Stock', sku: "53-000001",  to: "Shelf 1", quantity: "3"  }
    assert_redirected_to "/display_transfer_request_screen/53-000001/Shelf%201/0"
    assert flash[:notice] == "Success"
    assert Bin.find_by(sku_id: 2, location_id: 1).qty = 3
  end

  #
  # Remove from stock
  #
  test "display transfer result with removing non existing from to stock" do
    get "/set_session_name", params: {commit: "Submit", user_name: "TechA", user_password: "john"}
    get "/display_transfer_result", params:
      { commit: 'Remove from Stock', sku: "80-123456", from: "Shelf 1", quantity: "1"  }
    assert_redirected_to "/display_transfer_request_screen/80-123456/Shelf%201/0"
    assert flash[:alert] == "Couldn't find Sku"
  end

  test "display transfer result with removing existing from to stock below zero" do
    get "/set_session_name", params: {commit: "Submit", user_name: "TechA", user_password: "john"}
    get "/display_transfer_result", params:
      { commit: 'Remove from Stock', sku: "80-000000", from: "Shelf 1", quantity: "100" }
    #FIXME this shouldn't go to -84, should be zero with a warning
    assert_redirected_to "/display_transfer_request_screen/80-000000/Shelf%201/-84"
    assert flash[:alert] == "Validation failed: Qty Attempt to take quantity below zero"
  end

  test "display transfer result with removing existing stock destroying bin" do
    get "/set_session_name", params: {commit: "Submit", user_name: "TechA", user_password: "john"}
    assert Bin.find_by(sku_id: 1, location_id: 1).qty == 16
    get "/display_transfer_result", params:
      { commit: 'Remove from Stock', sku: "80-000000", from: "Shelf 1", quantity: "16" }
    assert_redirected_to "/display_transfer_request_screen/80-000000/Shelf%201/0"
    assert flash[:notice] == "Success"
    assert Bin.find_by(sku_id: 1, location_id: 1).nil?
  end


  test "display transfer result with removing non-existing from to stock" do
    get "/set_session_name", params: {commit: "Submit", user_name: "TechA", user_password: "john"}
    get "/display_transfer_result", params:
      { commit: 'Remove from Stock', sku: "80-123456", from: "Shelf 1",  quantity: "1"  }
    assert_redirected_to "/display_transfer_request_screen/80-123456/Shelf%201/0"
    assert flash[:alert] == "Couldn't find Sku"
  end

  test "transfer from a to b" do
    get "/set_session_name", params: {commit: "Submit", user_name: "TechA", user_password: "john"}

    #Verify we start with 16
    old_count_1 = Bin.find_by(sku_id: 1, location_id: 1).qty
    assert old_count_1 == 16   #from fixture
    assert Bin.find_by(sku_id: 1, location_id: 2).qty == 4, "Expected 4, saw #{Bin.find_by(sku_id: 1, location_id: 2).qty}"

    #assert Bin.find_by(sku_id: 1, location_id: 2).nil?
    get "/display_transfer_result", params:
      { commit: 'Submit', sku: "80-000000", from: "Shelf 1", to: "Shelf 2", quantity: "3", comment: "" }
    #FIXME why is the last character below zero instead of 3?
    assert_redirected_to "/display_transfer_request_screen/80-000000/Shelf%201/13/Shelf%202/"
    assert flash[:notice] == "Success"
    assert Bin.find_by(sku_id: 1, location_id: 1).qty == old_count_1 - 3
    assert Bin.find_by(sku_id: 1, location_id: 2).qty == 7, "Expected 7, saw #{Bin.find_by(sku_id: 1, location_id: 2).qty}"

    #Do it again, with an additional quantity
    old_count_1 = Bin.find_by(sku_id: 1, location_id: 1).qty
    old_count_2 =  Bin.find_by(sku_id: 1, location_id: 2).qty
    assert old_count_1 == 13, "Expected 13, saw #{assert old_count_1.to_s}"
    assert old_count_2 == 7, "Expected 7, saw #{assert old_count_1.to_s}"

    get "/display_transfer_result", params:
      { commit: 'Submit', sku: "80-000000", from: "Shelf 1", to: "Shelf 2", quantity: "2", comment: "" }
    assert_redirected_to "/display_transfer_request_screen/80-000000/Shelf%201/11/Shelf%202/"
    assert flash[:notice] == "Success"
    assert Bin.find_by(sku_id: 1, location_id: 1).qty == old_count_1 - 2
    assert Bin.find_by(sku_id: 1, location_id: 2).qty == old_count_2 + 2
  end

  test "transfer from a to b destroying source bin and creating dest bin (changed)" do
    get "/set_session_name", params: {commit: "Submit", user_name: "TechA", user_password: "john"}
    old_count_1 = Bin.find_by(sku_id: 1, location_id: 1).qty
    assert old_count_1 == 16   #from fixture

    #assert Bin.find_by(sku_id: 1, location_id: 2).nil?
    get "/display_transfer_result", params:
      { commit: 'Submit', sku: "80-000000", from: "Shelf 1", to: "Shelf 2", quantity: "16", comment: "" }
    assert_redirected_to "/display_transfer_request_screen/80-000000/Shelf%201/0/Shelf%202/"
    assert flash[:notice] == "Success"
    assert Bin.find_by(sku_id: 1, location_id: 1).nil?
    assert Bin.find_by(sku_id: 1, location_id: 2).qty == 20, "Expected 0, saw #{Bin.find_by(sku_id: 1, location_id: 2).qty}"
  end

  test "transfer non-existing from a to b" do
    get "/set_session_name", params: {commit: "Submit", user_name: "TechA", user_password: "john"}
    get "/display_transfer_result", params:
      { commit: 'Submit', sku: "80-000006", from: "Shelf 1", to: "Shelf 2", quantity: "1", comment: ""}
    assert_redirected_to "/display_transfer_request_screen/80-000006/Shelf%201/1/Shelf%202/"
    assert flash[:alert] == "Could not find SKU with that number", "Expected flash Could not find SKU with that number, got #{flash[:alert]}"
  end

  test "transfer excess quantity from a to b" do
    get "/set_session_name", params: {commit: "Submit", user_name: "TechA", user_password: "john"}
    old_count = Bin.find_by(sku_id: 2, location_id: 2).qty
    assert Bin.find_by(sku_id: 2, location_id: 1).nil?
    get "/display_transfer_result", params:
      { commit: 'Submit', sku: "53-000001", from: "Shelf 2", to: "Shelf 1", quantity: "300", comment: "" }
    assert_redirected_to "/display_transfer_request_screen/53-000001/Shelf%202/300/Shelf%201/"
    assert flash[:alert] == "Validation failed: Qty Attempt to take quantity below zero"
    assert Bin.find_by(sku_id: 2, location_id: 2).qty == old_count
    assert Bin.find_by(sku_id: 2, location_id: 1).nil?
  end

  test "transfer from a to b with bad source location" do
    get "/set_session_name", params: {commit: "Submit", user_name: "TechA", user_password: "john"}
    assert Bin.find_by(sku_id: 2, location_id: 1).nil?
    get "/display_transfer_result", params:
      { commit: 'Submit', sku: "80-000000", from: "Shelf 1a", to: "Shelf 2", quantity: "3", comment: "" }
    assert_redirected_to "/display_transfer_request_screen/80-000000/Shelf%201a/3/Shelf%202/"
    assert flash[:alert] == "Could not find that source location name", "Expected flash of Could not find that source location name, got #{flash[:alert]}"
    assert Bin.find_by(sku_id: 2, location_id: 1).nil?
  end

  test "transfer from a to b with good source location, but no bin" do
    get "/set_session_name", params: {commit: "Submit", user_name: "TechA", user_password: "john"}
    assert Bin.find_by(sku_id: 2, location_id: 1).nil?
    get "/display_transfer_result", params:
      { commit: 'Submit', sku: "53-000001", from: "Shelf 1", to: "Shelf 2", quantity: "1", comment: "" }
    assert_redirected_to "/display_transfer_request_screen/53-000001/Shelf%201/1/Shelf%202/"
    assert flash[:alert] == "Could not find a quantity of requested SKU in requested location", "Expected flash of Could not find a quantity of requested SKU in requested location, got #{flash[:alert]}"
    assert Bin.find_by(sku_id: 2, location_id: 1).nil?
  end


  test "transfer from a to b with bad dest location" do
    get "/set_session_name", params: {commit: "Submit", user_name: "TechA", user_password: "john"}
    old_count = Bin.find_by(sku_id: 1, location_id: 1).qty
    get "/display_transfer_result", params:
      { commit: 'Submit', sku: "80-000000", from: "Shelf 1", to: "Shelf 2a", quantity: "3", comment: "" }
    assert_redirected_to "/display_transfer_request_screen/80-000000/Shelf%201/3/Shelf%202a/"
    assert flash[:alert] == "Could not find destination location", "Expected flash of Could not find destination location, got #{flash[:alert]}"

    assert Bin.find_by(sku_id: 1, location_id: 1).qty == old_count
  end


  test "view the new sku screen" do
    get "/set_session_name", params: {commit: "Submit", user_name: "TechA", user_password: "john"}
    get "/display_new_sku_request_screen"
    assert_response :success
    assert response.body =~ /Add SKU with: new sku, new location, and initial quantity/
  end

  test "make a new sku with new loc and qty" do
    get "/set_session_name", params: {commit: "Submit", user_name: "TechA", user_password: "john"}
    get "/display_new_sku_result", params: {
      commit: "Create",
      sku_string: "NEW-STRING-SKU",
      description_string: "NEW-SKU-DESCRIPTION",
      comment_string: "NEW-SKU-TYPE-COMMENT",
      bu_string: "NEW-BU",
      cost_string: "$1.11",
      category_string: "ABC",
      stock_level_string: "4",
      location_string: "NEW-STRING-LOC",
      location_comment_string: "NEW-LOCATION-COMMENT",
      quantity: "3" }

    #assert_response :success
    get "/sku_matching.json/*"
    assert_response :success
    assert JSON.parse(response.body)[-1]['sku_num'] == 'NEW-STRING-SKU'
    assert JSON.parse(response.body)[-1]['loc'] == 'NEW-STRING-LOC'
    #comment doesn't show here...
    assert JSON.parse(response.body)[-1]['bu'] == 'NEW-BU'
    assert JSON.parse(response.body)[-1]['description'] == 'NEW-SKU-DESCRIPTION'
    assert JSON.parse(response.body)[-1]['category'] == 'ABC'
    assert JSON.parse(response.body)[-1]['cost'] == '$1.11'
    assert JSON.parse(response.body)[-1]['extended'] == '$3.33'

    assert JSON.parse(response.body)[-1]['qty'] ==  3

    #FIXME also chedk the transactions to see if it's there
    #FIXME also check the report to note that it's below reorder point
  end


end
