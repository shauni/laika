
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

  setup do |patient|
    @kind = test_type.kind
    @patient = patient
    @vendors = current_user.vendors + Vendor.unclaimed
    @vendor_test_plan = VendorTestPlan.new(:user_id => current_user.id)
  end

  # XDS P&R assign callback, executed on test_type.assign(opt).
  assign do |vendor_test_plan|
    vendor_test_plan.metadata = params[:metadata]
    vendor_test_plan.save!

    @metadata = params[:metadata]
    render 'testop/xds_provide_and_register/assign'
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

  setup do |patient|
    @kind = test_type.kind
    @patient_identifier = patient.patient_identifier
    @metadata = XDSUtils.list_document_metadata(@patient_identifier)
    @vendors = current_user.vendors + Vendor.unclaimed
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

