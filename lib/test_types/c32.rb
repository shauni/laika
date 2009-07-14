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

TestType.register("C32 Display and File") do
  execution :checklist

  checklist do |vendor_test_plan|
    @patient = vendor_test_plan.patient
    render 'testop/c32_display_and_file/checklist.xml', :layout => false
  end
end

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

