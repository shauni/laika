class TestopController < ApplicationController
  protected

  def test_type
    @test_type ||= TestType.get(params.delete(:test_type))
  end

  public

  # /patient/:patient_id/testop/:test_type/setup
  def setup
    page_title "#{test_type} setup"
    patient = Patient.find params[:patient_id]
    begin
      test_type.with_context(self).setup patient
      render "testop/#{test_type.to_param}/setup"
    rescue ActionController::DoubleRenderError
      # ignore double render
    end
  end

  # /vendor_test_plans/:vendor_test_plan_id/testop/:test_type/:test_operation
  def perform_test_operation
    test_operation   = params.delete(:test_operation)
    vendor_test_plan = VendorTestPlan.find params.delete(:vendor_test_plan_id)
    page_title "#{test_type} #{test_operation}" 

    begin
      if vendor_test_plan.user == current_user || current_user.administrator?
        test_type.with_context(self).perform(test_operation, vendor_test_plan, params)
      else
        flash[:notice] = 'You are not authorized to perform this operation.'
      end

      redirect_to vendor_test_plans_url
    rescue ActionController::DoubleRenderError
      # ignore double render
    end
  end

end

