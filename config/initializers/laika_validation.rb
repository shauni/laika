require 'xml_helper'
require 'laika/constants'

require 'validation'
require 'validators/c62'
require 'validators/c32_validator'
require 'validators/schema_validator'
require 'validators/schematron_validator'
require 'validators/umls_validator'
require 'validators/xds_metadata_validator'

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

require_dependency 'xml_helper'
require_dependency 'laika/constants'


# Requiring this initializes the validators.
# Validator initialization was moved from here
# into lib/validation.rb to address #104
# See lib/validation.rb comments for details.
require_dependency 'validation'
