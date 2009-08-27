class TestPlansController < ApplicationController
  page_title 'Laika Dashboard'

  include SortOrder
  self.valid_sort_fields = %w[ created_at updated_at patients.name type ]

  before_filter :set_test_plan, :except => [:index, :create]
  before_filter :set_vendor, :only => [:index]

  protected

  attr_reader :test_plan

  def set_test_plan
    @test_plan = TestPlan.find params[:id]
  end

  def set_vendor
    @vendor = Vendor.find_by_id(params[:vendor_id])
    if @vendor.nil?
      vendor = last_selected_vendor || current_user.vendors.first
      if vendor
        redirect_to vendor_test_plans_path(vendor)
      else
        flash[:notice] = 'You have not yet created any vendor inspections.'
        redirect_to patients_path
      end
    else
      self.last_selected_vendor_id = @vendor.id
    end
  end

  public

  include C32DisplayAndFilePlan::Actions
  include C32GenerateAndFormatPlan::Actions
  include XdsPlan::Actions
  include XdsProvideAndRegisterPlan::Actions
  include PixPdqPlan::Actions
  include PixFeedPlan::Actions
  
  def index
    @test_plans = @vendor.test_plans.all(:order => sort_order)
    @other_vendors = current_user.vendors - [@vendor]
  end

  def create
    test_type = params[:test_plan].delete(:type).constantize
    patient = Patient.find params[:patient_id]
    plan = test_type.new params[:test_plan].merge(:user => current_user)
    if plan.valid?
      TestPlan.transaction do
        plan.save!
        patient = patient.clone
        patient.test_plan = plan
        patient.save!
        flash[:notice] = "Created a new #{test_type.test_name} test plan."
        self.last_selected_vendor_id = params[:test_plan][:vendor_id]
      end
      redirect_to :action => :index
    else
      @plan = plan
      @patient = patient
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

