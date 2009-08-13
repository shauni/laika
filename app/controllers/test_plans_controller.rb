class TestPlansController < ApplicationController
  page_title 'Laika Dashboard'

  include SortOrder
  self.valid_sort_fields = %w[ created_at updated_at patients.name type ]

  before_filter :set_test_plan, :except => [:index, :create]

  protected

  attr_reader :test_plan

  def set_test_plan
    @test_plan = TestPlan.find params[:id]
  end

  public

  include C32DisplayAndFilePlan::Actions
  include C32GenerateAndFormatPlan::Actions
  #include XdsProvideAndRegisterPlan::Actions
  #include XdsQueryAndRetrievePlan::Actions
  #include PixFeedControllerPlan::Actions
  #include PixQueryControllerPlan::Actions
  #include PdqQueryControllerPlan::Actions
  
  def index
    @vendor = last_selected_vendor || current_user.vendors.first
    @test_plans = @vendor.test_plans.all(:order => sort_order)
    @other_vendors = current_user.vendors - [@vendor]
  end

  def create
    test_type = params[:test_plan].delete(:type).constantize
    plan = test_type.new params[:test_plan].merge(:user => current_user)
    if plan.valid?
      plan.save!
      flash[:notice] = "Created a new #{test_type.test_name} test plan."
      self.last_selected_vendor_id = params[:test_plan][:vendor_id]
      redirect_to :action => :index
    else
      @plan = plan
      render "test_plans/create_#{plan.parameterized_name}"
    end
  end

  def destroy
    test_plan.destroy if test_plan.user == current_user
    redirect_to test_plans_path
  end

  def mark
    if test_plan.user == current_user
      case params['state']
      when "pass"; test_plan.pass!
      when "fail"; test_plan.fail!
      end
    end
    redirect_to test_plans_url
  end

end

