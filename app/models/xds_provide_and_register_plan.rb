class XdsProvideAndRegisterPlan < XdsPlan
  test_name 'XDS Provide & Register'

  def validate_xds_metadata metadata_of_interest
    if metadata_of_interest
      validator = Validators::XdsMetadataValidator.new
      validation_errors = validator.validate test_plan_data, metadata_of_interest
      if validation_errors.empty?
        content_errors.clear
        pass
      else
        content_errors << validation_errors
        fail
      end
      cdoc = ClinicalDocument.new \
        :uploaded_data => XDSUtils.retrieve_document(metadata_of_interest)
      update_attributes :clinical_document => cdoc
    else
      content_errors << ContentError.new(
        :error_message => "Unable to find metadata in the XDS Registry",
        :validator => "XDS Metadata Validator",
        :inspection_type => 'XDS Provide and Register')
      fail
    end
  end
end
