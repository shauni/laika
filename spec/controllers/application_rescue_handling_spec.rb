require File.dirname(__FILE__) + '/../spec_helper'

class TestRescueController < ApplicationController
  
  skip_before_filter :login_required

  def application_error 
    raise(RuntimeError,'application error')
  end

end

# Note, these test names are repetitive because spec does not take into account the enclosing
# describe() blocks when generating the actual test method, leading to duplication of test
# methods if we don't specify the it() calls uniquely.
describe TestRescueController do

  before do
    ExceptionNotifier.exception_recipients = ['foo@bar.com']
    ActionMailer::Base.deliveries = []
  end

  describe "when consider_all_requests_local true" do

    before do
      ApplicationController.consider_all_requests_local = true
    end

    describe "and REMOTE_ADDR is local" do

      before do
        @request.remote_addr = '127.0.0.1'
      end

      it "should render unknown_action trace for local call with local address to action_does_not_exist" do
        assert_action_does_not_exist_renders_unknown_action
      end

      it "should rescue application errors with dev trace when local call has local address" do
        assert_application_error_renders_dev_trace
      end

      it "should not send email for application errors when local call has local address" do
        assert_application_error_sends_no_email
      end

    end

    describe "and REMOTE_ADDR is public" do

      before do
        @request.remote_addr = '67.23.24.57'
      end

      it "should render unknown_action trace for local call with public address to action_does_not_exist" do
        assert_action_does_not_exist_renders_unknown_action
      end

      it "should rescue application errors with dev trace when local call has public address" do
        assert_application_error_renders_dev_trace
      end

      it "should not send email for application errors when local call has public address" do
        assert_application_error_sends_no_email
      end

    end

    describe "and REMOTE_ADDR is nil" do

      before do
        @request.remote_addr = nil
      end

      it "should render unknown_action trace for local call with nil address to action_does_not_exist" do
        assert_action_does_not_exist_renders_unknown_action
      end

      it "should rescue application errors with dev trace when local call has nil address" do
        assert_application_error_renders_dev_trace
      end

      it "should not send email for application errors when local call has nil address" do
        assert_application_error_sends_no_email
      end

    end

  end

  describe "when consider_all_requests_local false" do

    before do
      ApplicationController.consider_all_requests_local = false 
    end

    describe "and REMOTE_ADDR is local" do

      before do
        @request.remote_addr = '127.0.0.1'
      end

      it "should render unknown_action trace for public call with local address to action_does_not_exist" do
        assert_action_does_not_exist_renders_unknown_action
      end

      it "should rescue application errors with dev trace when public call has local address" do
        assert_application_error_renders_dev_trace
      end

      it "should not send email for application errors when public call has local address" do
        assert_application_error_sends_no_email
      end

    end

    describe "and REMOTE_ADDR is public" do

      before do
        @request.remote_addr = '67.23.24.57'
      end

      it "should render 404 for public call with public address to action_does_not_exist" do
        assert_action_does_not_exist_renders_404
      end

      it "should render 500 for application error when public call has public address" do
        assert_application_error_renders_500
      end

      it "should not send email for application errors when public call has public address but no delivery addresses" do
        ExceptionNotifier.exception_recipients = []
        assert_application_error_sends_no_email
      end

      it "should send email for application errors when public call has public address and there are delivery addresses" do
        assert_application_error_sends_email
      end

    end

    describe "and REMOTE_ADDR is nil" do

      before do
        @request.remote_addr = nil
      end

      it "should render 404 for public call with nil address to action_does_not_exist" do
        assert_action_does_not_exist_renders_404
      end

      it "should render 500 for application error when public call has nil address" do
        assert_application_error_renders_500
      end

      it "should not send email for application errors when public call has nil address but no delivery addresses" do
        ExceptionNotifier.exception_recipients = []
        assert_application_error_sends_no_email
      end

      it "should send email for application errors when public call has nil address and there are delivery addresses" do
        assert_application_error_sends_email
      end

    end

  end

  def with_test_routes
    with_routing do |set|
      set.draw do |map|
        map.connect ':controller/:action/:id'
      end
      yield
    end
  end

  def assert_action_does_not_exist_renders_unknown_action
    assert_action_with_routes(:action_does_not_exist) do
      assert_response :not_found
      assert_template 'rescues/unknown_action.erb'
    end
  end

  def assert_action_does_not_exist_renders_404
    assert_action_with_routes(:action_does_not_exist) do
      assert_response :not_found
      assert_template '404.html'
    end
  end

  def assert_application_error_renders_dev_trace
    assert_action_with_routes(:application_error) do
      assert_response :internal_server_error
      assert_template 'rescues/diagnostics.erb' 
      assert_select('title', /Exception caught/)
      assert_select('body', /RuntimeError/)
    end
  end

  def assert_application_error_renders_500
    assert_action_with_routes(:application_error) do
      assert_response :internal_server_error
      assert_template '500.html' 
    end
  end

  def assert_application_error_sends_no_email
    assert_action_with_routes(:application_error) do
      assert ActionMailer::Base.deliveries.empty?
    end
  end

  def assert_application_error_sends_email
    assert_action_with_routes(:application_error) do
      assert !ActionMailer::Base.deliveries.empty?
    end
  end

  def assert_action_with_routes(action)
    with_test_routes do
      get action
      yield
    end
  end
 
end
