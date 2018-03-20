require 'watir'
require 'minitest/autorun'

class WatirMainTest < ActionDispatch::IntegrationTest


    setup do #before each test
        # put --headless in the switches to avoid showing pages
        system("fuser -k 3000/tcp")
        system("rails s -d -p 3000")
        @b = Watir::Browser.new :chrome, :switches => %w{ :headless }
        @b.goto 'http://localhost:3000'
        @b.wait
        @b.wait_until { @b.text.include? "Login" }

    end

    teardown do #after each test
        @b.close
        system("fuser -k 3000/tcp")
    end

    test 'it shows properly formatted title' do
      puts "doing regular login"
     #FIXME needs an if env
      SimpleCov.command_name "regular_login"
      ###@b.a(id: "logout_id").link.when_present.click
      ###@b.wait
      @b.text_field( id: "user_name_id").set("TechA")
      @b.text_field( id: "user_password_id").set("john")
      @b.button( text: "Submit").click
      @b.wait
      @b.wait_until { @b.text.include? "Welcome back, TechA" }
      assert @b.title =~ /Sea Urchin \d+\.\d+\.\d+e$/
      @b.a(id: "logout_id").click
      @b.wait
      @b.li(id: "logout_link_id").click
      @b.wait_until { @b.text.include? "Login" }
      assert @b.a(id: "logout_id").inner_html =~ /Login/

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
