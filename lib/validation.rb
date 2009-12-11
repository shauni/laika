module Validation
   def Validation.unregister_validators
     ValidationRegistry.instance.unregister_validators
   end
   
   def Validation.register_validator(doc_type, validator)
     ValidationRegistry.instance.register_validator(doc_type, validator)
   end
   
   def Validation.get_validator(type)
     ValidationRegistry.instance.get_validator(type)
   end
   
   def Validation.validate(patient_data, document)
     get_validator(document.doc_type).validate(patient_data,document)
   end

   def Validation.types
     ValidationRegistry.instance.types
   end

   class InvalidValidatorException < Exception
   end
   
   # this is just a stubbed out marker class to we can ensure that
   # everything that is registered as a validator really is one
   class BaseValidator
     
     
     
     def validate(patient_data, document)
         raise "Implement me damn it"
     end
     
   end
   
  class Validator
   
    attr_accessor :validators
    @validators = []
    @doc_type
    
    def initialize(doc_type)
      @validators = []
      @doc_type= doc_type
    end
    
    def validate(patient_data, document)
      errors = []       
      validators.each do |validator|
        errors.concat(validator.validate(patient_data,document))
      end

      errors
    end
    
    
    def << (validator)

         raise InvalidValidatorException if !validator.kind_of? Validation::BaseValidator
         validators << validator
    end
    
    def contains?(validator)
      validators.include?(validator)
    end
    
    def contains_kind_of?(validator)
      validators.any? {|v| v.kind_of?(validator)}
    end
  end 
  
  class ValidationRegistry
    include Singleton
    attr_reader :validators, :types

    def initialize()
       @validators={}
       @types = Set.new
    end

    def unregister_validators
      initialize
    end

    def register_validator(doc_type, validator)
      @types << doc_type
        
        raise InvalidValidatorException if !validator.kind_of? Validation::BaseValidator
        
        doc_validator = get_validator(doc_type)
        doc_validator << validator unless doc_validator.contains?(validator)
    end


    def get_validator(type)
      # just to make sure everything is normalized to capitalized symbols
      doc_type = type.class == Symbol ? type.to_s.upcase.to_sym : type.upcase.to_sym
      validator = @validators[doc_type]
      unless validator
        validator = Validator.new(type)
        @validators[doc_type] = validator
      end
      validator
    end

  end
end

# XXX Evaluate a better validator initialization strategy.
#
# This was moved to allow the config/initializers/laika_validation.rb
# step to use require_dependency instead of require.  Using require
# was causing github issue #104 with config.cache_classes = false
# because requiring validators/c32_validator would load an instance
# of MatchHelper which Rails would not track in its dependency tracking
# while other models would also load MatchHelper such that it would
# be tracked for reloading by Rails, with subsequent conflict:
#
# http://www.ruby-forum.com/topic/153066
# http://spacevatican.org/2008/9/28/required-or-not
#
# In summary: it is fine to require external sources (third party libraries
# and such), but requiring internal code that will reference other code
# which Rails will be doing dependency tracking on leads to pain.  Use
# require_dependency instead.
#
# The problem with keeping this code in the initializer even after
# require has been switched to require_dependency, is that with
# config.cache_classes = false, this file is reloaded with each request and
# a new Singleton ValidationRegistry is created.  Without the code below,
# it will not be initialized with any validators.
#
# Possible alternatives:
# 
# * use a global constant in the initializer?
# * use a singleton as the global constant in the initializer?
# * ?
# 
# It also may be worthwhile to sort out the module naming/pathing
# for all the validators so that Rails can find these classes
# for reloading in development (cache_classes = false) mode.
#
# (The reason cache_classes = false in production mode is 
# tied to issue #62...)
require_dependency 'validators/c62'
require_dependency 'validators/c32_validator'
require_dependency 'validators/schema_validator'
require_dependency 'validators/schematron_validator'
require_dependency 'validators/umls_validator'
require_dependency 'validators/xds_metadata_validator'


{
  'C32 v2.1/v2.3' => [
    Validators::C32Validation::Validator.new,
    Validators::Schema::Validator.new("C32 Schema Validator",
      "#{RAILS_ROOT}/resources/schemas/infrastructure/cda/C32_CDA.xsd"),
    Validators::Schematron::CompiledValidator.new("CCD Schematron Validator",
      "#{RAILS_ROOT}/resources/schematron/ccd_errors.xslt"),
    Validators::Schematron::CompiledValidator.new("C32 Schematron Validator",
      "#{RAILS_ROOT}/resources/schematron/c32_v2.1/c32_v2.1_errors.xslt"),
    Validators::Umls::UmlsValidator.new("warning")
  ],
  'C32 v2.4' => [
    Validators::C32Validation::Validator.new,
    Validators::Schema::Validator.new("C32 Schema Validator",
      "#{RAILS_ROOT}/resources/schemas/infrastructure/cda/C32_CDA.xsd"),
    Validators::Schematron::CompiledValidator.new("CCD Schematron Validator",
      "#{RAILS_ROOT}/resources/schematron/ccd_errors.xslt"),
    Validators::Schematron::CompiledValidator.new("C32 Schematron Validator",
      "#{RAILS_ROOT}/resources/schematron/c32_v2.4/c32_v2.4_errors.xslt"),
    Validators::Umls::UmlsValidator.new("warning")
  ],
  'C32 v2.5' => [
    Validators::C32Validation::Validator.new,
    Validators::Schema::Validator.new("C32 Schema Validator",
      "#{RAILS_ROOT}/resources/schemas/infrastructure/cda/C32_CDA.xsd"),
    Validators::Schematron::CompiledValidator.new("CCD Schematron Validator",
      "#{RAILS_ROOT}/resources/schematron/ccd_errors.xslt"),
    Validators::Schematron::CompiledValidator.new("C32 Schematron Validator",
      "#{RAILS_ROOT}/resources/schematron/c32_v2.5/c32_v2.5_errors.xslt"),
    Validators::Umls::UmlsValidator.new("warning")
  ],
  'NHIN C32' => [
    Validators::C32Validation::Validator.new,
    Validators::Schema::Validator.new("C32 Schema Validator",
      "#{RAILS_ROOT}/resources/schemas/infrastructure/cda/C32_CDA.xsd"),
    Validators::Schematron::CompiledValidator.new("CCD Schematron Validator",
      "#{RAILS_ROOT}/resources/schematron/ccd_errors.xslt"),
    Validators::Schematron::CompiledValidator.new("C32 Schematron Validator",
      "#{RAILS_ROOT}/resources/schematron/c32_v2.1_errors.xslt"),
    Validators::Schematron::CompiledValidator.new("NHIN Schematron Validator",
      "#{RAILS_ROOT}/resources/nhin_schematron/nhin_errors.xsl"),
    Validators::Umls::UmlsValidator.new("warning")
  ],
  'C62' => [ Validators::C62::Validator.new ]
}.each do |type, validators|
  validators.each do |validator|
    Validation.register_validator type.to_sym, validator
  end

end

