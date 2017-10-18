require 'test_helper'
require 'ostruct'

class TransactionsControllerTest < ActionDispatch::IntegrationTest

  test "get list of all transactions" do

    get "/transactions_found"
    assert_response :success
    z = JSON.parse(response.body)

    assert z.length == 2
    assert z[0]['sku'] == "80-000000"
    assert OpenStruct.new(z[0]).sku == "80-000000"
    assert z[1]['sku'] == "53-000001"

  end


end
