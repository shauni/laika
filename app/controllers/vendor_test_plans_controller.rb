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
    begin
      Patient.transaction(:requires_new => true) do
        patient = Patient.find(params[:patient_id]).clone

        vtp = patient.vendor_test_plan = VendorTestPlan.create!(params[:vendor_test_plan])
        vtp.user = current_user if not current_user.administrator?

        if params[:metadata]
          if params[:metadata].kind_of?(String)
            vtp.metadata = YAML.load(params[:metadata])         
          else
            params[:metadata][:source_patient_info] = patient.source_patient_info
            md = XDS::Metadata.new
            md.from_hash(params[:metadata], AFFINITY_DOMAIN_CONFIG)
            md.repository_unique_id = XDS_REPOSITORY_UNIQUE_ID
            md.unique_id  = patient.registration_information.person_identifier
            md.patient_id = patient.registration_information.person_identifier
            vtp.metadata = md
          end
          if vtp.metadata 
            doc = XDSUtils.retrieve_document(vtp.metadata)
            cd = ClinicalDocument.new(:uploaded_data=>doc)
            vtp.clinical_document = cd
            cd.save!
          end
        end

        vtp.save!
        patient.save!

        # save the vendor/kind selections for next time
        self.last_selected_vendor_id = vtp.vendor_id
        self.last_selected_kind_id   = vtp.kind_id
      end
    rescue XDSUtils::RetrieveFailed => e
      flash[:notice] = "Failed to retrieve document from XDS: #{e}"
    rescue ActiveRecord::RecordInvalid => e
      # FIXME should be using record.class.human_name but
      # https://rails.lighthouseapp.com/projects/8994/tickets/2120
      flash[:notice] = %{
        Failed to create #{e.record.class.name.underscore.humanize}:
        #{e.record.errors.full_messages.join("\n")}
      }
    end

    redirect_to vendor_test_plans_path
  end

  # DELETE /vendor_test_plans/1
  def destroy
    vendor_test_plan = VendorTestPlan.find(params[:id])
    if vendor_test_plan.user == current_user || current_user.administrator?
      vendor_test_plan.destroy
    end
    redirect_to vendor_test_plans_path
  end

  def inspect_content
    @vendor_test_plan = VendorTestPlan.find(params[:id])
  end

  # perform the external validation and display the results
  def validate 
    @vendor_test_plan = VendorTestPlan.find(params[:id])  
  end

  def validatepix
    @vendor_test_plan = VendorTestPlan.find(params[:id])
    @patient = @vendor_test_plan.patient
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
  
  def xds_query_checklist
    @vendor_test_plan = VendorTestPlan.find(params[:id])
    @metadata = @vendor_test_plan.metadata
    render :layout => false
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
  

  def validate_p_and_r
    @vendor_test_plan = VendorTestPlan.find(params[:id])
    @vendor_test_plan.validate_xds_provide_and_register
  end

end
