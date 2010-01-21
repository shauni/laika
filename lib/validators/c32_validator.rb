# Initial cut at separating the C32 validation routines form the models.  All
# this currently does is to reinject the models with the validation classes.
# The C32Validator then just calls the validate 32 method on the pateint data
# object

# FIXME Requiring files using the full path is bad practice.
# Ideally we should rename/namespace the *C32Validation modules so that they
# can be autoloaded by Rails.
Dir.glob(File.join(File.dirname(__FILE__), 'c32/*.rb')).each {|f| require f }

module Validators
  
  module C32Validation
    C32VALIDATOR = "C32Validator"
       
    def self.add_validation_routines
      [
        :act_status_code,
        :address,
        :advance_directive,
        :advance_directive_status_code,
        :advance_directive_type,
        :allergy,
        :allergy_status_code,
        :allergy_type_code,
        :comment,
        :condition,
        :encounter,
        :encounter_location_code,
        :encounter_type,
        :immunization,
        :information_source,
        :insurance_provider,
        :insurance_provider_guarantor,
        :insurance_provider_patient,
        :insurance_provider_subscriber,
        :insurance_type,
        :language,
        :medical_equipment,
        :medication,
        :patient,
        :person_name,
        :problem_type,
        :procedure,
        :provider,
        :provider_role,
        :provider_type,
        :registration_information,
        :result,
        :result_type_code,
        :severity_term,
        :support,
        :telecom,
        :vaccine,
        :vital_sign,
      ].each do |klass|
        # tablelize is to help classify handle singulars ending in 's' like :address
        klass.to_s.tableize.classify.constantize.send(:include,"#{klass}_c32_validation".classify.constantize)
      end
    end

    class Validator < Validation::BaseValidator

      def validate(patient,document)
        unless patient.respond_to? "validate_c32"
          C32Validation.add_validation_routines
        end
        
        errors = patient.validate_c32(document)
        # set the validator field for the errors
         errors.each do |e|
            e.validator = C32VALIDATOR
            e.inspection_type = ::CONTENT_INSPECTION
          end
        return errors
      end

    end

  end

end

# load it up to begin with
Validators::C32Validation.add_validation_routines
