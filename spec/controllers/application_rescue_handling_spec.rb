require File.dirname(__FILE__) + '/../spec_helper'

class ApplicationController

  def application_error
    raise(RuntimeError,'application error')
  end

end

describe ApplicationController do

  describe "when consider_all_requests_local true" do

    before do
      ApplicationController.consider_all_requests_local = true
    end

    describe "and REMOTE_ADDR is local" do

      before do
        @request.remote_addr = '127.0.0.1'
      end

      it "should rescue routing errors with dev trace" do
        get :action_does_not_exist 
      end

      it "should rescue application errors with dev trace"
      it "should not send email"
    end

    describe "and REMOTE_ADDR is public" do
      it "should rescue routing errors with dev trace"
      it "should rescue application errors with dev trace"
      it "should not send email"

    end

    describe "and REMOTE_ADDR is nil" do
      it "should rescue routing errors with dev trace"
      it "should rescue application errors with dev trace"
      it "should not send email"

    end

  end

  describe "when consider_all_requests_local false" do

    describe "and REMOTE_ADDR is local" do

      it "should rescue routing errors with dev trace"
      it "should rescue application errors with dev trace"
      it "should not send email"

    end

    describe "and REMOTE_ADDR is public" do

      it "should rescue routing errors with 404"
      it "should rescue application errors with 500"
      it "should send email"

    end

    describe "and REMOTE_ADDR is nil" do

      it "should rescue routing errors with 404"
      it "should rescue application errors with 500"
      it "should not send email"

    end

  end

end
