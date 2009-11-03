class GenerateAndFormatPlan < TestPlan
  test_name "Generate & Format"
  pending_actions 'Execute>' => :doc_upload
  completed_actions 'Inspect' => :doc_inspect, 'Checklist' => :doc_checklist
  serialize :test_type_data, Hash

  # Use these relations to access content errors by inspection_type.
  # The *_INSPECTION constants are set in config/initializers/laika_globals.rb
  has_many :xml_validation_errors, :class_name => 'ContentError',
    :foreign_key => 'test_plan_id',
    :conditions => { :inspection_type => ::XML_VALIDATION_INSPECTION }
  has_many :content_inspection_errors, :class_name => 'ContentError',
    :foreign_key => 'test_plan_id',
    :conditions => { :inspection_type => ::CONTENT_INSPECTION }
  has_many :umls_codesystem_errors, :class_name => 'ContentError',
    :foreign_key => 'test_plan_id',
    :conditions => { :inspection_type => ::UMLS_CODESYSTEM_INSPECTION }

  class ValidationError < StandardError; end

  def initialize *args
    super
    self.test_type_data ||= {}
  end

  # @return true if UMLS is enabled for this test, false otherwise.
  def umls_enabled?
    !!test_type_data[:umls_enabled]
  end

  # Used by validate_clinical_document_content to indicate whether UMLS
  # was used. You can check for this flag by calling umls_enabled?
  def umls_enabled= flag
    test_type_data[:umls_enabled] = flag
  end

  # This is the primary validation operation for Generate and Format.
  def validate_clinical_document_content
    document = clinical_document.as_xml_document
    validator = Validation.get_validator(clinical_document.doc_type)

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
    def doc_upload
      render 'test_plans/doc_upload', :layout => !request.xhr?
    end

    def doc_validate
      test_plan.update_attributes! :clinical_document =>
        ClinicalDocument.create!(params[:clinical_document])
      begin
        test_plan.validate_clinical_document_content
      rescue ValidationError
        flash[:notice] = "An error occurred while validating the document"
      end
      redirect_to test_plans_url
    end
    
    def doc_checklist
      clinical_document = test_plan.clinical_document
      
      doc = clinical_document.as_xml_document(true)
      
      if doc.root && doc.root.name == "ClinicalDocument"
        pi = REXML::Instruction.new('xml-stylesheet', 
          'type="text/xsl" href="' + relative_url_root + 
          '/schemas/generate_and_format.xsl"')
        doc.insert_after(doc.xml_decl, pi)
        render :xml => doc.to_s
      else
        redirect_to clinical_document.public_filename
      end
    end
    
    def doc_inspect
      if @test_plan.clinical_document.nil?
        flash[:notice] = "There is no clinical document content to inspect."
        redirect_to test_plans_url
      else
        @xml_document = @test_plan.clinical_document.as_xml_document
        # XXX match_errors sets @error_attributes, used by the node partial
        @error_mapping = match_errors @test_plan.content_errors, @xml_document
      end
    end
  end
end

