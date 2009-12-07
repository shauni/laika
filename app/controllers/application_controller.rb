# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

# Uses the exception_notification plugin
module LaikaExceptionNotification
  def self.included(target)
    # hook in exception_notification plugin
    # and decorate render_500 with render_500_with_ajax
    target.class_eval do 
      include ExceptionNotifiable
      include Decorator
      # decorate ExceptionNotifiable
      alias_method_chain :render_500, :ajax
      alias_method_chain :local_request?, :guard
      alias_method_chain :rescue_action_in_public, :recipients_check
    end 
  end

  module Decorator 

    # Decorate's ExceptionNotifiable's local_request? because glassfish is not
    # providing remote_ip for localhost at least.
    def local_request_with_guard?
      logger.info("request.remote_ip: #{request.remote_ip}")
      request.remote_ip.blank? ? false : local_request_without_guard?
    end

    # Decorates ExceptionNotifiable's render_500 to handle 500 errors returned
    # for Ajax requests.
    def render_500_with_ajax
      if request.xhr?
        render :update, :status => '500' do |page|
          page.alert("An internal error occurred, please report this to #{FEEDBACK_EMAIL}.")
        end
      else
        render_500_without_ajax
      end
    end

    # Decorates ExceptionNotifiable's rescue_action_in_public in order to 
    # skip delivery if no exception_recipients have been sent.
    def rescue_action_in_public_with_recipients_check(exception)
      if ExceptionNotifier.exception_recipients.empty?
        # just render the exception message
        case exception
          when *self.class.exceptions_to_treat_as_404
            render_404
          else
            render_500
        end
      else
        # render and send exception message
        rescue_action_in_public_without_recipients_check(exception)
      end 
    end
  end
end
  
class ApplicationController < ActionController::Base

  # When handling exceptions send out emails to admins configured in config/laika.yml
  include LaikaExceptionNotification

  # AuthenticationSystem supports the acts_as_authenticated
  include AuthenticatedSystem

  filter_parameter_logging :password

  # "remember me" functionality
  before_filter :login_from_cookie

  before_filter :login_required

  # See ActionController::RequestForgeryProtection for details
  protect_from_forgery
  
  protected

  # Set the last selected vendor by id. The value is saved in the session.
  #
  # This method is used by TestPlan#create to retain previous selections as a convenience
  # in the UI.
  def last_selected_vendor_id=(vendor_id)
    session[:previous_vendor_id] = vendor_id
  end

  # Get the last selected vendor from the session.
  def last_selected_vendor
    begin
      Vendor.find_by_id(session[:previous_vendor_id]) if session[:previous_vendor_id]
    rescue ActiveRecord::StatementInvalid
    end
  end

  # Set the page title for the controller, can be overridden by calling
  # page_title in any controller action.
  def self.page_title(title)
    class_eval %{
      before_filter :set_page_title
      def set_page_title
        @page_title = %{#{title}}
      end
    }
  end

  # Set the page title for the current action.
  def page_title(title)
    @page_title = title
  end

  def require_administrator
    if current_user.try(:administrator?)
      true
    else
      redirect_to test_plans_url
      false
    end
  end

end
