
TestType.register("C32 Display and File") do
  execution :checklist

  # POST vendor_test_plans/1/testop/c32_display_and_file/checklist
  checklist do |vendor_test_plan|
    @patient = vendor_test_plan.patient
    render 'testop/c32_display_and_file/checklist.xml', :layout => false
  end
end

TestType.register("C32 Generate and Format") do
  execution :upload_document, :validate

  # POST vendor_test_plans/1/testop/c32_generate_and_format/update_document
  upload_document do |vendor_test_plan|
    @vendor_test_plan = vendor_test_plan
    render 'testop/c32_generate_and_format/upload_document', :layout => false
  end

  # POST vendor_test_plans/1/testop/c32_generate_and_format/validate
  validate do |vendor_test_plan|
    clinical_document = ClinicalDocument.new(params[:clinical_document])
    vendor_test_plan.clinical_document = clinical_document
    begin
      vendor_test_plan.validate_clinical_document_content
    rescue # XXX rescuing everything is almost never a good idea
      flash[:notice] = "An error occurred while validating the document"
    end
    redirect_to vendor_test_plans_url
  end
end

