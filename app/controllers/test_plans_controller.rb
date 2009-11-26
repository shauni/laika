class TestPlansController < ApplicationController
  page_title 'Laika Dashboard'

  include SortOrder
  self.valid_sort_fields = %w[ type updated_at ]

  before_filter :set_test_plan, :except => [:index, :create]
  before_filter :set_vendor, :only => [:index]
  before_filter :check_print_preview, :only => [:doc_inspect, :pix_pdq_inspect, :xds_inspect]

  protected

  attr_reader :test_plan

  # Set the test plan using the +id+ parameter.
  def set_test_plan
    @test_plan = current_user.test_plans.find params[:id]
  end

  # Set the vendor using the +vendor_id+ parameter.
  #
  # If there is no +vendor_id+ then a vendor is selected and the user is
  # redirected to a vendor-specific dashboard. If the user has no vendors
  # the user is redirected to the library.
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

  # method used to mark the elements in the document that have errors so they 
  # can be linked to
  def match_errors(errors, doc)
    error_map = {}
    error_id = 0
    @error_attributes = []
    locs = errors.collect{|e| e.location}
    locs.compact!

    locs.each do |location|
      node = REXML::XPath.first(doc ,location)
      if(node)
        elem = node
        if node.class == REXML::Attribute
          @error_attributes << node
          elem = node.element
        end
        if elem
          unless elem.attributes['error_id']
            elem.add_attribute('error_id',"#{error_id}") 
            error_id += 1
          end
          error_map[location] = elem.attributes['error_id']
        end
      end
    end

    error_map
  end

  public

  include C32DisplayAndFilePlan::Actions
  include GenerateAndFormatPlan::Actions
  include NhinDisplayAndFilePlan::Actions
  include XdsPlan::Actions
  include XdsProvideAndRegisterPlan::Actions
  include PixPdqPlan::Actions
  include PixFeedPlan::Actions
  include C62InspectionPlan::Actions
  
  # Display all test plans by vendor.
  def index
    @test_plans = @vendor.test_plans.all :order => sort_order,
      :include => [ :patient, :proctor, :clinical_document ]
    @other_vendors = current_user.vendors - [@vendor]
  end

  # Assign patient data to a test plan, optionally creating a new inspection.
  # Patient data is cloned before assignment.
  #
  # This method assembles a new test plan and verifies that it is valid. If
  # the test plan is not valid (i.e., additional data is required) a template
  # determined based on the plan type name is rendered. For instance, XDS
  # Provide & Register test type would result in the rendering of the
  # template "test_plans/create_xds_provide_and_register". This template
  # can be used to collect additional data needed for test plan creation.
  #
  # @param [String] type Test plan class name.
  # @param [Hash] test_plan Test plan data.
  # @param [Number] patient_id Source patient/template ID.
  # @param [Optional String] vendor_name Name for a new vendor.
  def create
    test_type = params[:test_plan].delete(:type).constantize
    patient = Patient.find params[:patient_id]
    plan = test_type.new params[:test_plan].merge(:user => current_user)
    if plan.vendor.nil?
      vendor_name = params[:vendor_name]
      begin
        plan.vendor = Vendor.create!(:public_id => vendor_name, :user_id => current_user.id)
      rescue ActiveRecord::RecordInvalid => e
        flash[:notice] = "Failed to create inspection #{vendor_name}: #{e}"
        redirect_to patients_url
        return
      end
    end
    if plan.valid?
      TestPlan.transaction do
        plan.save!
        patient = patient.clone
        patient.user = current_user
        patient.test_plan = plan
        patient.save!
        flash[:notice] = "Created a new #{test_type.test_name} test plan."
        self.last_selected_vendor_id = plan.vendor.id
      end
      redirect_to :action => :index
    else
      @plan = plan
      @patient = patient
      render "test_plans/create_#{plan.parameterized_name}"
    end
  end

  # Delete a test plan.
  #
  # @param [Number] id Test plan ID.
  def destroy
    test_plan.destroy if test_plan.user == current_user
    redirect_to test_plans_path
  end

  # Mark a test plan as passed or failed.
  # This can only be used on pending test plans.
  #
  # @param [Number] id Test plan ID.
  # @param ["pass", "fail"] state Intended test state.
  def mark
    test_plan.override_state!(params[:test_plan])
    redirect_to test_plans_url
  end

  # Duplicate an existing test plan so that it can be performed again.
  #
  # @param [Number] id Test plan ID.
  def clone
    test_plan.clone
    redirect_to test_plans_url
  end

  protected

    # Checks to see if a parameter :print_preview == 1.
    # If this has been passed in, sets @print_preview to true which
    # the layout can use to adjust stylesheets for print rather than screen.
    def check_print_preview
      @print_preview = params[:print_preview] == '1'
    end
end

