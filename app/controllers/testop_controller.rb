class TestopController < ApplicationController

  # /vendor_test_plans/:vendor_test_plan_id/testop/:test_type/:test_operation
  def perform_test_operation
    test_operation   = params.delete(:test_operation)
    test_type        = TestType.get(params.delete(:test_type)).with_context(self)
    vendor_test_plan = VendorTestPlan.find params.delete(:vendor_test_plan_id)

    begin
      if vendor_test_plan.user == current_user || current_user.administrator?
        test_type.perform(test_operation, vendor_test_plan, params)
      else
        flash[:notice] = 'You are not authorized to perform this operation.'
      end

      redirect_to vendor_test_plans_url
    rescue ActionController::DoubleRenderError
      # ignore double render
    end
  end

end

