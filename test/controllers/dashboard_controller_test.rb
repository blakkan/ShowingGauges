require 'test_helper'

class DashboardControllerTest < ActionDispatch::IntegrationTest

  test "display dashboard" do
    get "/set_session_name", params: {commit: "Submit", user_name: "TechA", user_password: "john"}
    ##NOTE:  This is just a dumnmy display of C3 items
    get "/display_dashboard"
    assert_response :success
    assert response.body =~ /Vertical bar chart/
  end

  test "display advanced search screen" do
    get "/set_session_name", params: {commit: "Submit", user_name: "TechA", user_password: "john"}
    get "/display_advanced_search_screen"
    assert_response :success
  end

  test "display reorder table" do
    get "/set_session_name", params: {commit: "Submit", user_name: "TechA", user_password: "john"}
    get "/display_reorder_table"
    assert_response :success
  end


test "get list of all skus in json for the bootstrap-table" do
  get "/set_session_name", params: {commit: "Submit", user_name: "TechA", user_password: "john"}

  get "/data.json"
  assert_response :success
  z = JSON.parse(response.body)

  assert z.length == 1, "Expected 1, got #{z.length}"
  assert OpenStruct.new(z[0]).name == "53-000001"
  assert OpenStruct.new(z[0]).quantity == 4
  assert OpenStruct.new(z[0]).reorder == 24
end


test "get list of all skus in csv for export" do
  get "/set_session_name", params: {commit: "Submit", user_name: "TechA", user_password: "john"}

  get "/data.csv"
  assert_response :success
  assert response.header["Content-Type"] == "text/csv"
  the_stuff= CSV.parse(response.body)
  assert the_stuff.flatten ==  ["SKU", "Quantity", "Reorder-point", "53-000001", "4", "24"]
  #assert the_stuff[0][0] == [["SKU", "Quantity", "Reorder-point"], ["53-000001", "4", "24"]]

end


end
