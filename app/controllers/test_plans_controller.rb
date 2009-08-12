class TestPlansController < ApplicationController
  include SortOrder
  self.valid_sort_fields = %w[ created_at updated_at patients.name type ]

  def index
    @vendor = last_selected_vendor || current_user.vendors.first
    @test_plans = @vendor.test_plans.all(:order => sort_order)
    @other_vendors = current_user.vendors - [@vendor]
  end

  def create
    test_type = TestPlan.get params[:test_plan].delete(:type)
    plan = test_type.new params[:test_plan].merge(:user => current_user)
    if plan.valid?
      plan.save!
      flash[:notice] = "Created a new #{test_type.test_name} test plan."
      self.last_selected_vendor_id = params[:test_plan][:vendor_id]
      redirect_to :action => :index
    else
      @plan = plan
      render :template => "test_plans/create_#{@plan.parameterized_name}"
    end
  end
end

