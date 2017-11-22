require 'watir'
require 'minitest/autorun'

class WatirMainTest < ActionDispatch::IntegrationTest

    setup do #before each test
        # put --headless in the switches to avoid showing pages
        @b = Watir::Browser.new :chrome, :switches => %w{ :headless }
        @b.goto 'http://localhost:3000'
        @b.wait
        @b.wait_until { @b.text.include? "Login" }
        @b.text_field( id: "user_name_id").set("TechA")
        @b.text_field( id: "user_password_id").set("john")
        @b.button( text: "Submit").click
        @b.wait
        @b.wait_until { @b.text.include? "Welcome back, TechA" }
    end

    teardown do #after each test
        @b.close
    end

    test 'it shows properly formatted title' do
      assert @b.title =~ /Sea Urchin \d+\.\d+\.\d+$/
    end

    test 'it shows properly formatted title second time' do
      assert @b.title =~ /Sea Urchin \d+\.\d+\.\d+$/
    end

end
