require_dependency 'sort_order'

class XdsPatientsController < ApplicationController
  page_title 'XDS Registry'

  include SortOrder
  self.valid_sort_fields = %w[ name created_at updated_at ]

  def index
    @patients = Patient.find(:all,
      :conditions => {:vendor_test_plan_id => nil},
      :order => sort_order || 'name ASC')
      
    @vendors = current_user.vendors + Vendor.unclaimed

    @previous_vendor = last_selected_vendor
  end
  
  def query
    pi = PatientIdentifier.find(params[:id])
    @metadata = XDSUtils.list_document_metadata(pi)
    @vendors = current_user.vendors + Vendor.unclaimed
    @patient_identifier = pi
    @kind = Kind.find_by_name('Query and Retrieve')
  end

  # Creates the form that collects data for a provide and register test
  def provide_and_register_setup
    @patient = Patient.find(params[:id])
    @vendors = current_user.vendors + Vendor.unclaimed
    @kind = Kind.find_by_name('Provide and Register').id
    @vendor_test_plan = VendorTestPlan.new(:user_id => current_user.id)
  end

  # Creates the form that collects data to actuall provide and register a document to an XDS Repository
  def provide_and_register
    @patient = Patient.find(params[:id])
  end
  
  def do_provide_and_register
    pd = Patient.find(params[:pd_id])
    params[:metadata][:source_patient_info] = pd.source_patient_info

    md = XDS::Metadata.new
    md.from_hash(params[:metadata], AFFINITY_DOMAIN_CONFIG)

    md.unique_id = pd.generate_unique_id
    md.repository_unique_id = XDS_REPOSITORY_UNIQUE_ID
    md.patient_id = pd.patient_identifier
    md.mime_type = 'text/xml'
    md.ss_unique_id = "1.3.6.1.4.1.21367.2009.1.2.1.#{Time.now.to_i}"
    md.source_id = "1.3.6.1.4.1.21367.2009.1.2.1"
    md.language_code = 'en-us'
    md.creation_time = Time.now.to_s(:brief)

    response = XDSUtils.provide_and_register(md, pd.to_c32)
    if response.success?
      flash[:notice] = "Provide and Register successful"
    else
      flash[:notice] = "Provide and Register failed #{response.errors.inspect}"
    end
    redirect_to :action => :index
  end

end
