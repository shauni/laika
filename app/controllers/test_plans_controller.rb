class TestPlansController < ApplicationController
  include SortOrder

  self.valid_sort_fields = %w[ created_at updated_at patients.name type ]
  def index
    @vendor = current_user.current_vendor
    @test_plans = @vendor.test_plans
    @other_vendors = current_user.vendors - [@vendor]
  end

  def create
    test_type = TestPlan.get params[:test_plan].delete(:type)
    test_type.create params[:test_plan].merge(:user => current_user)
    flash[:notice] = "Created a new test plan."
    redirect_to :action => :index
  end
end
