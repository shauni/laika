require "rubygems"
require "selenium/client"
require "test/unit"

# This test was built quickly to reproduce GH#130 - the out of memory error.
# It's not set up to be run on any workstation, as it expects a particular log in
# You will need to edit the email and password submitted for log in below.
#
# To run this test, you will need to have the selenium-client gem and you will
# need to have an instance of Laika running on localhost:3000.  You will also need
# to have loaded the default data, and you will have to have added at least one
# test plan.
# 
# Run:
#
# jruby -S rake selenium:rc:start
#
# to start up a selenium server instance
#
# Then run:
#
# ruby test/selenium/heap_overflow_test.rb
#
# Note, I haven't tried this with jruby - I don't know if there is a selenium-client
# gem for jruby, though there probably is.
#
# This test assumes a 500MB heap.
class Untitled < Test::Unit::TestCase
  def setup
    @verification_errors = []
    if $selenium
      @selenium = $selenium
    else
      @selenium = Selenium::Client::Driver.new("localhost", 4444, "*chrome", "http://localhost:3000/", 10000);
      @selenium.start
    end
    @selenium.set_context("test_untitled")
  end
  
  def teardown
    @selenium.stop unless $selenium
    assert_equal [], @verification_errors
  end
  
  def test_untitled
    @selenium.open "/account/login"
    @selenium.type "email", "jpartlow@opensourcery.com"
    @selenium.type "password", "password"
    @selenium.click "link=Login"
    @selenium.wait_for_page_to_load "300000"
    30.times do |i|
      puts "Attempting Generate and Format: #{i}"
      generate_and_format
    end
  end

  def generate_and_format
    @selenium.click "link=Library"
    @selenium.wait_for_page_to_load "300000"
    @selenium.click "link=Add to Test Plan"
    @selenium.select "test_plan_type", "label=Generate & Format"
    @selenium.click "//input[@value='Assign']"
    @selenium.wait_for_page_to_load "300000"
    @selenium.click "link=Execute", :wait_for => :ajax
    @selenium.type "//input[starts-with(@id,'upload')]", "/home/jpartlow/dev/osourcery/elbe/laika/spec/test_data/joe_c32.xml"
    @selenium.click "//input[@name='commit' and @value='Attach']"
    @selenium.wait_for_page_to_load "300000"
  end
end
