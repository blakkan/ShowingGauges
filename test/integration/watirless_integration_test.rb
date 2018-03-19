require 'test_helper'
require 'ostruct'

class WatirlessIntegrationTest < ActionDispatch::IntegrationTest

  #This doesn't start a real browser, unlike the WatirMain test

    setup do #before each test


    end

    teardown do #after each test

    end

    test 'it shows the properly formatted title' do

      get "/", params: {}
      assert_response :success
      assert_select "title", {:count => 1, :text=>"Sea Urchin 0.0.1d"}


    end

    test 'fail to log in with no name' do
      get "/", params: {}
      assert_response :success
      get "/set_session_name", params: {commit: "Submit"}
      assert_response :redirect
      assert response.redirect_url == "http://www.example.com/display_login_screen"
      follow_redirect!
      assert_response :success
      assert_equal flash[:alert], "No user by that name"
    end

    test 'properly login with name' do
      get "/set_session_name", params: {commit: "Submit", user_name: "TechA", user_password: "john"}
      assert_response :redirect
      assert response.redirect_url == "http://www.example.com/display_find_skus_screen", "Expected successfull login, got #{response.redirect_url}"
      follow_redirect!
      assert_response :success
      assert_equal flash[:notice], "Welcome back, TechA"

    end

    test "result of good password change" do
      get "/set_session_name", params: { commit: "Change Password", user_name: "TechA", user_password: "john" }
      assert_response :redirect
      assert response.redirect_url == "http://www.example.com/display_change_password_screen"
      follow_redirect!
      assert_response :success
      get "/change_password_result",
        params: { user_password: "surin", user_password2: "surin"}
      assert_redirected_to "/"
      assert flash[:notice] == "Password Changed"
      assert User.find_by(name: "TechA").encrypted_password == "0b7fd68dc76c504eb325ae4c9bed0d07"  #surin
    end


#    test 'Google login shows properly formatted title' do
#      puts "doing google login"
#      #FIXME needs an if env
#      SimpleCov.command_name "google_login"
#      ###@b.a(id: "logout_id").link.when_present.click
#      ###@b.wait
#      @b.text_field( id: "user_name_id").set("TechA")
#      #@b.text_field( id: "user_password_id").set("john")
#      @b.button( text: "Login with Google").click
#      puts "got instruction"
#      Watir::Wait.until { @b.div(id: "flash_notice").present? }
#      puts "now seeing flash"
#      assert @b.title =~ /Sea Urchin \d+\.\d+\.\d+$/
#      assert @b.div(id: "flash_notice").inner_html =~ /Welcome back, TechA/,
#        "Expected welcome back of TechA, but got [#{@b.div(id: "flash_notice").inner_html}]"
#      @b.a(id: "logout_id").click
#    end


end
