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

  test "display transfer result with cancel" do
    get "/set_session_name", params: {commit: "Submit", user_name: "TechA", user_password: "john"}
    get "/display_transfer_result", params:
      { commit: 'Cancel', sku: "80-123456", from: "Shelf 1", to: "Shelf 2", quantity: "0"  }
    assert_redirected_to "/display_transfer_request_screen/80-123456/Shelf%201/0"
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
    old_count_1 = Bin.find_by(sku_id: 1, location_id: 1).qty
    #assert Bin.find_by(sku_id: 1, location_id: 2).nil?
    get "/display_transfer_result", params:
      { commit: 'Submit', sku: "80-000000", from: "Shelf 1", to: "Shelf 2", quantity: "3" }
    #FIXME why is the last character below zero instead of 3?
    assert_redirected_to "/display_transfer_request_screen/80-000000/Shelf%201/7"
    assert flash[:notice] == "Success"
    assert Bin.find_by(sku_id: 1, location_id: 1).qty == old_count_1 - 3
    assert Bin.find_by(sku_id: 1, location_id: 2).qty == 7, "Expected 7, saw #{Bin.find_by(sku_id: 1, location_id: 2).qty}"

    #Do it again, with an additional quantity
    old_count_1 = Bin.find_by(sku_id: 1, location_id: 1).qty
    old_count_2 =  Bin.find_by(sku_id: 1, location_id: 2).qty
    get "/display_transfer_result", params:
      { commit: 'Submit', sku: "80-000000", from: "Shelf 1", to: "Shelf 2", quantity: "2" }
    assert_redirected_to "/display_transfer_request_screen/80-000000/Shelf%201/9"
    assert flash[:notice] == "Success"
    assert Bin.find_by(sku_id: 1, location_id: 1).qty == old_count_1 - 2
    assert Bin.find_by(sku_id: 1, location_id: 2).qty == old_count_2 + 2
  end

  test "transfer from a to b destroying source bin and creating dest bin (changed)" do
    get "/set_session_name", params: {commit: "Submit", user_name: "TechA", user_password: "john"}
    old_count_1 = Bin.find_by(sku_id: 1, location_id: 1).qty
    #assert Bin.find_by(sku_id: 1, location_id: 2).nil?
    get "/display_transfer_result", params:
      { commit: 'Submit', sku: "80-000000", from: "Shelf 1", to: "Shelf 2", quantity: "16" }
    assert_redirected_to "/display_transfer_request_screen/80-000000/Shelf%201/20"
    assert flash[:notice] == "Success"
    assert Bin.find_by(sku_id: 1, location_id: 1).nil?
    assert Bin.find_by(sku_id: 1, location_id: 2).qty == 20, "Expected 20, saw #{Bin.find_by(sku_id: 1, location_id: 2).qty}"
  end

  test "transfer non-existing from a to b" do
    get "/set_session_name", params: {commit: "Submit", user_name: "TechA", user_password: "john"}
    get "/display_transfer_result", params:
      { commit: 'Submit', sku: "80-000006", from: "Shelf 1", to: "Shelf 2", quantity: "1" }
    assert_redirected_to "/display_transfer_request_screen/80-000006/Shelf%201/0"
    assert flash[:alert] == "Couldn't find Sku"
  end

  test "transfer excess quantity from a to b" do
    get "/set_session_name", params: {commit: "Submit", user_name: "TechA", user_password: "john"}
    old_count = Bin.find_by(sku_id: 2, location_id: 2).qty
    assert Bin.find_by(sku_id: 2, location_id: 1).nil?
    get "/display_transfer_result", params:
      { commit: 'Submit', sku: "53-000001", from: "Shelf 2", to: "Shelf 1", quantity: "300" }
    assert_redirected_to "/display_transfer_request_screen/53-000001/Shelf%202/0"
    assert flash[:alert] == "Validation failed: Qty Attempt to take quantity below zero"
    assert Bin.find_by(sku_id: 2, location_id: 2).qty == old_count
    assert Bin.find_by(sku_id: 2, location_id: 1).nil?
  end

  test "transfer from a to b with bad source location" do
    get "/set_session_name", params: {commit: "Submit", user_name: "TechA", user_password: "john"}
    assert Bin.find_by(sku_id: 2, location_id: 1).nil?
    get "/display_transfer_result", params:
      { commit: 'Submit', sku: "80-000000", from: "Shelf 1a", to: "Shelf 2", quantity: "3" }
    assert_redirected_to "/display_transfer_request_screen/80-000000/Shelf%201a/0"
    assert flash[:alert] == "Couldn't find Location"
    assert Bin.find_by(sku_id: 2, location_id: 1).nil?
  end

  test "transfer from a to b with bad dest location" do
    get "/set_session_name", params: {commit: "Submit", user_name: "TechA", user_password: "john"}
    old_count = Bin.find_by(sku_id: 1, location_id: 1).qty
    get "/display_transfer_result", params:
      { commit: 'Submit', sku: "80-000000", from: "Shelf 1", to: "Shelf 2a", quantity: "3" }
    assert_redirected_to "/display_transfer_request_screen/80-000000/Shelf%201/0"
    assert flash[:alert] == "Couldn't find Location"
    assert Bin.find_by(sku_id: 1, location_id: 1).qty == old_count
  end

end
