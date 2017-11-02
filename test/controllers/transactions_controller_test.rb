require 'test_helper'
require 'ostruct'

class TransactionsControllerTest < ActionDispatch::IntegrationTest

  test "get the transaction request screen" do

    get "/display_transactions_request_screen"
    assert_response :success

    # just look to see if there's one button for now.
    #TODO parse with Nokogiri and look for more stuff
    assert response.body =~ /Cancel/

  end

  test "The transaction reply screen" do
    get "/display_all_transactions", params:
      { start_date_name: '1900-01-01', end_date_name: '2101-01-01' }
    assert_response :success
    assert response.body =~ /transactions_found.json\/1900-01-01\/2101-01-01/


    get "/display_all_transactions", params:
      { start_date_name: '1900-01-01', end_date_name: '1900-01-02' }
    assert_response :success
    assert response.body =~ /transactions_found.json\/1900-01-01\/1900-01-02/

  end

  test "Transaction display date scrubbing" do

    get "/display_all_transactions", params:
      { start_date_name: '1900-01-01', end_date_name: '' }
    assert_response :success
    assert response.body =~ /transactions_found.json\/1900-01-01\/2101-01-01/

    get "/display_all_transactions", params:
      { start_date_name: '', end_date_name: '2101-01-01' }
    assert_response :success
    assert response.body =~ /transactions_found.json\/1901-01-01\/2101-01-01/

    get "/display_all_transactions", params:
      { start_date_name: '', end_date_name: '' }
    assert_response :success
    assert response.body =~ /transactions_found.json\/1901-01-01\/2101-01-01/

    get "/display_all_transactions", params:
      { start_date_name: 'Scooby-Doo', end_date_name: 'Where are you?' }
    assert_response :success
    assert response.body =~ /transactions_found.json\/1901-01-01\/2101-01-01/

  end

  test "cancel request for transactions" do
    get "/display_all_transactions", params:
      { commit: 'Cancel' }
    assert_redirected_to "/display_transactions_request_screen"
    assert flash[:notice] == "Operation Cancelled"
  end



  test "get list of all transactions in json for the bootstrap-table" do

    get "/transactions_found.json/1901-01-01/2101-01-01"
    assert_response :success
    z = JSON.parse(response.body)

    assert z.length == 2
    assert z[0]['sku_num'] == "80-000000"
    assert OpenStruct.new(z[0]).sku_num == "80-000000"
    assert z[1]['sku_num'] == "53-000001"

  end


end
