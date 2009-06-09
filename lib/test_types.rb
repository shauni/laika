
TestType.register("C32 Display and File")

TestType.register("C32 Generate and Format")

TestType.register("PDQ Query")

TestType.register("PIX Feed")

TestType.register("PIX Query")

TestType.register("XDS Provide and Register") do
  assign do |vendor_test_plan|
    vendor_test_plan.metadata = params[:metadata]
    vendor_test_plan.save!

    @metadata = params[:metadata]
    render 'xds_patients/assign_success'
  end
end

TestType.register("XDS Query and Retrieve") do
  assign do |vendor_test_plan|
    vendor_test_plan.metadata = params[:metadata]
    doc = XDSUtils.retrieve_document(vendor_test_plan.metadata)
    vendor_test_plan.clinical_document = ClinicalDocument.new(:uploaded_data=>doc)
    vendor_test_plan.clinical_document.save!
    vendor_test_plan.save!
  end
end

