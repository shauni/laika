
TestType.register("C32 Display and File")

TestType.register("C32 Generate and Format")

TestType.register("XDS Provide and Register") do
  assign do |vendor_test_plan|
    vendor_test_plan.metadata = params[:metadata]
    vendor_test_plan.save

    @metadata = params[:metadata]
    render 'xds_patients/assign_success'
  end
end

