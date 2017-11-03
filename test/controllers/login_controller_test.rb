require 'test_helper'
require 'nokogiri'

class LoginControllerTest < ActionDispatch::IntegrationTest

  test "display login screen" do

  end

  test "attempt to login with known user and good password" do
    get "/set_session_name", params: { commit: "Submit", user_name: "TechA", user_password: "john" }
    assert_redirected_to "/display_find_skus_screen"
    assert flash[:notice] == "Welcome back, TechA"
  end

  test "attempt to login with known user with blank password" do
    get "/set_session_name", params: { commit: "Submit", user_name: "TechB", user_password: "" }
    assert_redirected_to "/display_find_skus_screen"
    assert flash[:notice] == "Welcome back, TechB"
  end

  test "attempt to login with known user with no password" do
    get "/set_session_name", params: { commit: "Submit", user_name: "TechB" }
    assert_redirected_to "/display_find_skus_screen"
    assert flash[:notice] == "Welcome back, TechB"
  end

  test "attempt to login with known user and bad password" do
    get "/set_session_name", params: { commit: "Submit", user_name: "TechA", user_password: "johnx" }
    assert_redirected_to "/display_login_screen"
    assert flash[:alert] == "Incorrect Password"
  end

  test "attempt to login with unknown user" do
    get "/set_session_name", params: { commit: "Submit", user_name: "TechC", user_password: "john" }
    assert_redirected_to "/display_login_screen"
    assert flash[:alert] == "No user by that name"
  end

  test "attempt to go to change pw screen with known user and good password" do
    get "/set_session_name", params: { commit: "Change Password", user_name: "TechA", user_password: "john" }
    assert_redirected_to "/display_change_password_screen"

  end

  test "attempt to go to change pw screen with known user and bad password" do
    get "/set_session_name", params: { commit: "Change Password", user_name: "TechA", user_password: "johnx" }
    assert_redirected_to "/display_login_screen"
    assert flash[:alert] == "Incorrect Password"
  end

  test "attempt to go to change pw screen with unknown user" do
    get "/set_session_name", params: { commit: "Change Password", user_name: "TechAx", user_password: "johnx" }
    assert_redirected_to "/display_login_screen"
    assert flash[:alert] == "No user by that name"
  end

  test "result of password change with no match of new passwords" do
    get "/set_session_name", params: { commit: "Change Password", user_name: "TechA", user_password: "john" }
    assert_redirected_to "/display_change_password_screen"
    get "/change_password_result",
      params: { user_password: "a", user_password2: "b"}
    assert_redirected_to "/display_change_password_screen"
    assert flash[:alert] == "Failed: Passwords did not match"
  end

  test "result of good password change" do
    get "/set_session_name", params: { commit: "Change Password", user_name: "TechA", user_password: "john" }
    assert_redirected_to "/display_change_password_screen"
    get "/change_password_result",
      params: { user_password: "surin", user_password2: "surin"}
    assert_redirected_to "/"
    assert flash[:notice] == "Password Changed"
    assert User.find_by(name: "TechA").encrypted_password == "0b7fd68dc76c504eb325ae4c9bed0d07"  #surin
  end


end
