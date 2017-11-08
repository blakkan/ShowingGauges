require 'test_helper'

class BinsControllerTest < ActionDispatch::IntegrationTest


  test "display transfer request screen with sku, loc, and qty" do
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
    get "/display_transfer_result", params:
      { commit: 'Cancel', sku: "80-123456", from: "Shelf 1", to: "Shelf 2", quantity: "0"  }
    assert_redirected_to "/display_transfer_request_screen/80-123456/Shelf%201/0"
    assert flash[:notice] == "Action Cancelled"
  end

  #
  # Add to stock
  #
  test "display transfer result with add non-existing sku to stock" do
    get "/display_transfer_result", params:
      { commit: 'Add to Stock', sku: "80-000004",  to: "Shelf 1", quantity: "3"  }
    assert_redirected_to "/display_transfer_request_screen/80-000004/Shelf%201/0"
    #p flash
    #assert flash[:alert] == "Couldn't find Sku"
  end

  test "display transfer result with add existing sku to stock" do
    old_count = Bin.find_by(sku_id: 1, location_id: 1).qty
    get "/display_transfer_result", params:
      { commit: 'Add to Stock', sku: "80-000000",  to: "Shelf 1", quantity: "3"  }
    assert_redirected_to "/display_transfer_request_screen/80-000000/Shelf%201/#{(old_count + 3).to_s}"
    assert flash[:notice] == "Success"
    assert Bin.find_by(sku_id: 1, location_id: 1).qty = old_count + 3
  end

  #
  # Remove from stock
  #
  test "display transfer result with removing non existing from to stock" do
    get "/display_transfer_out_result", params:
      { commit: 'Remove from Stock', sku: "80-123456", from: "Shelf 1", quantity: "1"  }
    assert_redirected_to "/display_transfer_request_screen/80-123456/Shelf%201/0"
    assert flash[:alert] == "Couldn't find Sku"
  end

  test "display transfer result with removing existing from to stock below zero" do
    get "/display_transfer_out_result", params:
      { commit: 'Remove from Stock', sku: "80-000000", from: "Shelf 1", quantity: "100" }
    #FIXME this shouldn't go to -84, should be zero with a warning
    assert_redirected_to "/display_transfer_request_screen/80-000000/Shelf%201/-84"
    assert flash[:alert] == "Validation failed: Qty Attempt to take quantity below zero"
  end

  test "display transfer result with removing non-existing from to stock" do
    get "/display_transfer_out_result", params:
      { commit: 'Remove from Stock', sku: "80-123456", from: "Shelf 1",  quantity: "1"  }
    assert_redirected_to "/display_transfer_request_screen/80-123456/Shelf%201/0"
    assert flash[:alert] == "Couldn't find Sku"
  end

  test "transfer from a to b" do
  end

  test "transfer non-existing from a to b" do
  end

  test "transfer excess quantity from a to b" do
  end



end
