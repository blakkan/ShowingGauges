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

end
