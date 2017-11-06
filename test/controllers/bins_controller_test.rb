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

  test "display transfer result" do
    get "/display_transfer_result", params:
      { commit: 'Cancel', sku: "80-123456", from: "Shelf 1", to: "Shelf 2", quantity: "0"  }
    assert_redirected_to "/display_transfer_request_screen/80-123456/Shelf%201/0"
    assert flash[:notice] == "Action Cancelled"
  end


end
