
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
# Assign callbacks MUST accept a vendor_test_plan, which should be
# returned by the global callback. The return value doesn't matter.
# Assign callbacks are currently executed in controller context, so
# calls like redirect_to and params work as you'd expect.
#

TestType.register("C32 Display and File")

TestType.register("C32 Generate and Format")

TestType.register("PDQ Query")

TestType.register("PIX Feed")

TestType.register("PIX Query")

TestType.register("XDS Provide and Register") do
  # XDS P&R assign callback, executed on test_type.assign(opt).
  assign do |vendor_test_plan|
    vendor_test_plan.metadata = params[:metadata]
    vendor_test_plan.save!

    @metadata = params[:metadata]
    render 'xds_patients/assign_success'
  end
end

TestType.register("XDS Query and Retrieve") do
  # XDS Q&R assign callback, executed on test_type.assign(opt).
  assign do |vendor_test_plan|
    vendor_test_plan.metadata = params[:metadata]
    doc = XDSUtils.retrieve_document(vendor_test_plan.metadata)
    vendor_test_plan.clinical_document = ClinicalDocument.new(:uploaded_data=>doc)
    vendor_test_plan.clinical_document.save!
    vendor_test_plan.save!
  end
end

