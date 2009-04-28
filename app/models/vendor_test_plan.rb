class VendorTestPlan < ActiveRecord::Base

  has_one :patient, :foreign_key => :vendor_test_plan_id, :class_name => 'Patient', :dependent => :destroy
  belongs_to :vendor
  belongs_to :kind
  belongs_to :user

  has_one :test_result, :dependent => :destroy
  has_one :clinical_document, :dependent => :destroy
  has_many :content_errors, :dependent => :destroy
  
  serialize :metadata, XDS::Metadata

  #before_save :_bf
  #after_save :_bf
  def _bf
    puts self.errors
  end
  
  def validate_clinical_document_content
    document = clinical_document.as_xml_document
    validator = Validation.get_validator(clinical_document.doc_type)

    logger.debug(validator.inspect)
    errors = validator.validate(patient, document)
    logger.debug(errors.inspect)
    logger.debug("PD #{patient}  doc #{document}")

    content_errors.clear
    content_errors.concat errors
    content_errors
  end


  def count_errors_and_warnings
    errors = content_errors.count(:conditions=>["msg_type = 'error' "])
    warnings = content_errors.count(:conditions=>["msg_type = 'warning' "])
   
    return errors, warnings
  end

  def validate_xds_provide_and_register
    rsqr = XDS::RegistryStoredQueryRequest.new(XDS_REGISTRY_URLS[:register_stored_query], 
                                                {"$XDSDocumentEntryPatientId" => "'#{metadata.patient_id}'",
                                                 "$XDSDocumentEntryStatus" => "('urn:oasis:names:tc:ebxml-regrep:StatusType:Approved')"})
    content_errors.clear
    query_results = rsqr.execute
    if query_results
      metadata_of_interest = query_results.find {|qr| qr.unique_id == metadata.unique_id}
      if metadata_of_interest
        validator = Validators::XdsMetadataValidator.new
        validation_errors = validator.validate(metadata, metadata_of_interest)
        if validation_errors.empty?
          self.test_result = TestResult.new(:result => 'PASS')
        else
          content_errors << validation_errors
          self.test_result = TestResult.new(:result => 'FAIL')
        end
        cdoc = ClinicalDocument.new(:uploaded_data=>XDSUtils.retrieve_document(metadata_of_interest))
        self.clinical_document = cdoc
      else
        content_errors << ContentError.new(:error_message => "Unable to find metadata in the XDS Registry",
                                           :validator => "XDS Metadata Validator", :inspection_type => 'XDS Provide and Register')
        self.test_result = TestResult.new(:result => 'FAIL')
      end
    else
      
    end
  end

  # Build and return a CSV document with the contents of the given user's test plan.
  #
  # FIXME this (still) needs to be rewritten
  #
  # XXX also, does anyone use this? the output isn't even really CSV
  def self.export_csv(user)
    vendor_test_plans = user.vendor_test_plans
    vendors = Vendor.find(:all)

    report = "#{user.first_name} #{user.last_name}'s Inspections:\n"

    vendors.each do |vendor|
      seen_vendor = false
      vendor_test_plans.each do |vendor_test_plan|
        if vendor_test_plan.vendor_id == vendor.id
          if not seen_vendor
            report << "Vendor ID:,"
            report << vendor.public_id + "\n\n"	
            seen_vendor = true
          end	
          report << "Patient Name:,"
          report << vendor_test_plan.patient.name + "\n" 	
          report << "Inspection Type:,"
          report << vendor_test_plan.kind.name + "\n"
          report << "Result:,"
          error_count = 0
          if vendor_test_plan.clinical_document
            error_count = vendor_test_plan.content_errors.length	        	          
            if error_count > 0
              report << "failure\n"
              report << "Number of errors:, "
              report << error_count.to_s
              report << "\n"
            else
              report << "success\n"
              report << "Number of errors:, --\n"
            end
          else
            report << "in progress\n"
            report << "Number of errors:, --\n"		  				
          end
          report << "Last Modified:,"
          report << vendor_test_plan.updated_at.strftime("%d.%b.%Y")
          report << "\n\n"
        end
      end
    end
    report
  end

end
