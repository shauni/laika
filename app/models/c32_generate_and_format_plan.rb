class C32GenerateAndFormatPlan < TestPlan
  test_name "C32 Generate and Format"
  pending_actions 'Execute>' => :c32_upload
  completed_actions 'Inspect' => :c32_inspect, 'Checklist' => :c32_checklist
  serialize :test_type_data, Hash

  class ValidationError < StandardError; end

  def initialize *args
    super
    self.test_type_data ||= {}
  end

  # Return true if UMLS is enabled for this test, false otherwise.
  #
  # @return [true, false] UMLS-enabled flag
  def umls_enabled?
    !!test_type_data[:umls_enabled]
  end

  # Used by validate_clinical_document_content to indicate whether UMLS
  # was used. You can check for this flag by calling umls_enabled?
  #
  # @param [true, false] flag UMLS-enabled flag
  def umls_enabled= flag
    test_type_data[:umls_enabled] = flag
  end

  # This is the primary validation operation for C32 Generate and Format.
  def validate_clinical_document_content
    document = clinical_document.as_xml_document
    validator = Validation.get_validator(:C32)

    logger.debug(validator.inspect)
    errors = nil
    begin
      errors = validator.validate(patient, document)
    rescue Exception => e # XXX rescuing everything is almost never a good idea
      logger.info("ERROR DURING VALIDATION: #{e}")
      raise ValidationError
    end
    logger.debug(errors.inspect)
    logger.debug("PD #{patient}  doc #{document}")

    content_errors.clear
    content_errors.concat errors

    if validator.contains_kind_of?(Validators::Umls::UmlsValidator)
      self.umls_enabled = true
    end

    if content_errors.empty?
      pass
    else
      fail
    end

    content_errors
  end

  module Actions
    # Display a form requesting a C32 file for upload.
    def c32_upload
      render 'test_plans/c32_upload', :layout => !request.xhr?
    end

    # Validate a C32 file using this test plan.
    def c32_validate
      test_plan.update_attributes! :clinical_document =>
        ClinicalDocument.create!(params[:clinical_document])
      begin
        test_plan.validate_clinical_document_content
      rescue ValidationError
        flash[:notice] = "An error occurred while validating the document"
      end
      redirect_to test_plans_url
    end

    # Display the C32 inspection results.
    def c32_inspect
    end
  end
end

