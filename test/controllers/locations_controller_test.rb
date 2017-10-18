require 'test_helper'

class LocationsControllerTest < ActionDispatch::IntegrationTest

  test "get list of items in locations" do

    get '/shelf_item_matching.json/*'
    assert_response :success
    z = JSON.parse(response.body)
    assert z.length == 2

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
    assert z.length == 1

    get '/shelf_item_matching.json/*3'
    assert_response :success
    z = JSON.parse(response.body)
    assert z.length == 0

  end

end
