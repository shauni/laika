class C32GenerateAndFormatPlan < TestPlan
  test_name "C32 Generate and Format"
  pending_actions 'execute>' => :c32_upload
  completed_actions 'inspect' => :c32_inspect, 'checklist' => :c32_checklist

  def validate_clinical_document_content
    document = clinical_document.as_xml_document
    validator = Validation.get_validator(clinical_document.doc_type)

    logger.debug(validator.inspect)
    errors = validator.validate(patient, document)
    logger.debug(errors.inspect)
    logger.debug("PD #{patient}  doc #{document}")

    content_errors.clear
    content_errors.concat errors

    if validator.contains_kind_of?(::Validators::Umls::UmlsValidator)
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
    def c32_upload
      render 'test_plans/c32_upload', :layout => !request.xhr?
    end

    def c32_validate
      test_plan.update_attributes! :clinical_document =>
        ClinicalDocument.create!(params[:clinical_document])
      begin
        test_plan.validate_clinical_document_content
      rescue Exception => e # XXX rescuing everything is almost never a good idea
        logger.debug("ERROR DURING VALIDATION: #{e}")
        flash[:notice] = "An error occurred while validating the document"
      end
      redirect_to test_plans_url
    end
  end

  def c32_inspect
  end
end

