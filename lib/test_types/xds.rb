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

TestType.shared('XDS') do
  execution :checklist

  checklist do |vendor_test_plan|
    @metadata = vendor_test_plan.metadata
    @vendor_test_plan = vendor_test_plan
    render 'testop/xds/checklist', :layout => false
  end
end

TestType.register("XDS Provide and Register") do
  include_shared 'XDS'

  execution :select_document, :compare

  # XDS P&R assign callback, executed on test_type.assign(opt).
  assign do |vendor_test_plan|
    vendor_test_plan.metadata = params[:metadata]
    vendor_test_plan.save!

    @metadata = params[:metadata]
    render 'xds_patients/assign_success'
  end

  select_document do |vendor_test_plan|
    @metadata = XDSUtils.list_document_metadata(vendor_test_plan.patient.patient_identifier)
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
  include_shared 'XDS'

  # XDS Q&R assign callback, executed on test_type.assign(opt).
  assign do |vendor_test_plan|
    vendor_test_plan.metadata = params[:metadata]
    doc = XDSUtils.retrieve_document(vendor_test_plan.metadata)
    vendor_test_plan.clinical_document = ClinicalDocument.new(:uploaded_data=>doc)
    vendor_test_plan.clinical_document.save!
    vendor_test_plan.save!
  end
end

