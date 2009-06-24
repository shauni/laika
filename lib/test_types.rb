
#
# Global test callbacks
#
# These callbacks are executed for every test type. They're evaluated in the
# context of the current test type. In this context, the read-only accessor
# kind returns the corresponding Kind instance from the database.
#
TestType.global do
  # Assign callback, executed on test_type.assign(opt).
  #
  # This callback MUST return the newly created vendor_test_plan.
  assign do |opt|
    raise 'patient required' if not opt.key?(:patient)
    raise 'user required'    if not opt.key?(:user)
    raise 'vendor required'  if not opt.key?(:vendor)

    patient = opt[:patient].clone
    patient.create_vendor_test_plan(
      :kind   => kind, # test type accessor
      :vendor => opt[:vendor],
      :user   => opt[:user]
    )
    patient.save!
    patient.vendor_test_plan
  end
end

#
# Test type definitions
#
# For each test type, optional callbacks can be specified. Even if no
# callbacks are needed, the test name must be registered and it must 
# have a corresponding database record in the kinds table.
#
# All callbacks MUST accept a vendor_test_plan, which should be
# returned by the global callback. The return value doesn't matter.
#
# All callbacks are currently executed in controller context, so
# calls like redirect_to and params work as you'd expect.
#

TestType.register("C32 Display and File")

TestType.register("C32 Generate and Format") do
  execution :upload_document, :validate

  upload_document do |vendor_test_plan|
    @vendor_test_plan = vendor_test_plan
    render 'testop/c32_generate_and_format/upload_document', :layout => false
  end

  validate do |vendor_test_plan|
    clinical_document = ClinicalDocument.new(params[:clinical_document])
    vendor_test_plan.clinical_document = clinical_document
    begin
      vendor_test_plan.validate_clinical_document_content
    rescue # XXX rescuing everything is almost never a good idea
      flash[:notice] = "An error occurred while validating the document"
    end
  end
end

TestType.register("PDQ Query")

TestType.register("PIX Feed") do
  execution :gather_expected, :compare, :inspect

  gather_expected do |vendor_test_plan|
    @vendor_test_plan = vendor_test_plan
    render 'testop/pix_feed/gather_expected', :layout => false
  end

  compare do |vendor_test_plan|
    @vendor_test_plan = vendor_test_plan
    @test_result = TestResult.new(params[:test_result])

    @vendor_test_plan.patient.patient_identifiers.each do |pi|
      if pi.patient_identifier == @test_result.patient_identifier &&
          pi.affinity_domain == @test_result.assigning_authority
        @test_result.result = 'PASS'
        break
      end
    end

    @vendor_test_plan.test_result = @test_result
  end

  inspect do |vendor_test_plan|
    @vendor_test_plan = vendor_test_plan
    @patient = vendor_test_plan.patient
    render 'testop/pix_feed/results'
  end
end

TestType.register("PIX Query")

TestType.register("XDS Provide and Register") do
  execution :checklist
  execution :select_document, :compare

  # XDS P&R assign callback, executed on test_type.assign(opt).
  assign do |vendor_test_plan|
    vendor_test_plan.metadata = params[:metadata]
    vendor_test_plan.save!

    @metadata = params[:metadata]
    render 'xds_patients/assign_success'
  end

  checklist do |vendor_test_plan|
    @metadata = vendor_test_plan.metadata
    @vendor_test_plan = vendor_test_plan
    render 'testop/xds/checklist', :layout => false
  end
 
  select_document do |vendor_test_plan|
    rsqr = XDS::RegistryStoredQueryRequest.new(XDS_REGISTRY_URLS[:register_stored_query], {
      "$XDSDocumentEntryPatientId" => "'#{vendor_test_plan.patient.patient_identifier}'",
      "$XDSDocumentEntryStatus" => "('urn:oasis:names:tc:ebxml-regrep:StatusType:Approved')"
    })
    @metadata = rsqr.execute
    @vendor_test_plan = vendor_test_plan
    render 'testop/xds_provide_and_register/select_document'
  end

  compare do |vendor_test_plan|
    vendor_test_plan.validate_xds_provide_and_register(YAML.load(params[:metadata]))
    @vendor_test_plan = vendor_test_plan
    render 'testop/xds_provide_and_register/compare'
  end
end

TestType.register("XDS Query and Retrieve") do
  execution :checklist

  checklist do |vendor_test_plan|
    @metadata = vendor_test_plan.metadata
    @vendor_test_plan = vendor_test_plan
    render 'testop/xds/checklist', :layout => false
  end
 
  # XDS Q&R assign callback, executed on test_type.assign(opt).
  assign do |vendor_test_plan|
    vendor_test_plan.metadata = params[:metadata]
    doc = XDSUtils.retrieve_document(vendor_test_plan.metadata)
    vendor_test_plan.clinical_document = ClinicalDocument.new(:uploaded_data=>doc)
    vendor_test_plan.clinical_document.save!
    vendor_test_plan.save!
  end
end

