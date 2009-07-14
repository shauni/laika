require_dependency 'sort_order'

class VendorTestPlansController < ApplicationController
  page_title 'Laika Dashboard'
  include SortOrder
  self.valid_sort_fields = %w[ created_at updated_at patients.name kinds.name ]

  # GET /vendor_test_plans
  # GET /vendor_test_plans.xml
  def index
    respond_to do |format|
      format.html do
        @vendor_test_plans = {}
        @errors = {}
        @warnings = {}
        VendorTestPlan.find(:all, :include => [:kind, :patient], :conditions => {
          :user_id => current_user
        }, :order => sort_order || 'created_at ASC').each do |vendor_test_plan|
          (@vendor_test_plans[vendor_test_plan.vendor] ||= []) << vendor_test_plan
          if vendor_test_plan.clinical_document
            @errors[vendor_test_plan], @warnings[vendor_test_plan] = vendor_test_plan.count_errors_and_warnings
          end
        end
        @vendors = @vendor_test_plans.keys
      end
      format.csv do
        send_data VendorTestPlan.export_csv(current_user),
          :filename => "report.csv", :type => 'application/x-download'
      end
    end
  end

  # POST /vendor_test_plans
  def create

    # XXX until all tests are implemented using the TestType facilities
    # we need to continue using the database kinds.
    kind = Kind.find(params[:vendor_test_plan][:kind_id])
    test_type = kind.as_test_type.with_context(self)

    if test_type
      user = current_user.administrator? ?
        User.find(params[:vendor_test_plan][:user_id]) : current_user
      vendor  = Vendor.find(params[:vendor_test_plan][:vendor_id])
      patient = Patient.find(params[:patient_id]) # .clone?

      begin
        vtp = test_type.assign(
          :user => user,
          :vendor => vendor,
          :patient => patient
        )

        # save the vendor/kind selections for next time
        self.last_selected_vendor_id = vtp.vendor_id
        self.last_selected_kind_id   = vtp.kind_id

        redirect_to vendor_test_plans_url
      rescue ActionController::DoubleRenderError
        # This means redirect was called in the assign callback,
        # we should just ignore the second redirect.
        # XXX There must be a better way to do this. A guarded
        # render and redirect_to were considered but rejected
        # because they're not localized enough. At least this way
        # we only ignore double renders when we intend to.
      rescue TestType::AssignFailure => e
        flash[:notice] = "Assign failed: #{e}"
        redirect_to patients_url
      end
    else
      flash[:notice] = "Test type not configured: #{kind.display_name}"
      redirect_to patients_url
    end
  end

  # DELETE /vendor_test_plans/1
  def destroy
    vendor_test_plan = VendorTestPlan.find(params[:id])
    if vendor_test_plan.user == current_user || current_user.administrator?
      vendor_test_plan.destroy
    end
    redirect_to vendor_test_plans_path
  end

  # perform the external validation and display the results
  def validate 
    @vendor_test_plan = VendorTestPlan.find(params[:id])  
  end

  def checklist 
    @vendor_test_plan = VendorTestPlan.find(params[:id])
    clinical_document = @vendor_test_plan.clinical_document
    
    @doc = clinical_document.as_xml_document(true)
    
    if @doc.root && @doc.root.name == "ClinicalDocument"
      pi = REXML::Instruction.new('xml-stylesheet', 
        'type="text/xsl" href="' + 
        relative_url_root + 
        '/schemas/generate_and_format.xsl"')
      @doc.insert_after(@doc.xml_decl, pi)
      render :xml => @doc.to_s
    else
      redirect_to clinical_document.public_filename
    end
  end
  
  def set_status
    vendor_test_plan = VendorTestPlan.find(params[:id])
    if vendor_test_plan.user == current_user
      results = vendor_test_plan.test_result || TestResult.new(:vendor_test_plan_id=>vendor_test_plan.id)
      case params["status"]
        when "pass"
          results.result="PASS"
        when "fail"
          results.result = "FAIL"
        when "inprogress"
          results.result = "IN-PROGRESS"         
      end
      results.save!
    end
    redirect_to vendor_test_plans_url
  end
end
