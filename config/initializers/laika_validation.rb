require 'validation'
require 'validators/c32_validator'
require 'validators/schema_validator'
require 'validators/schematron_validator'
require 'validators/umls_validator'
require 'validators/xds_metadata_validator'
Validation.register_validator :C32, Validators::C32Validation::Validator.new
Validation.register_validator :C32, Validators::Schema::Validator.new("C32 Schema Validator", "resources/schemas/infrastructure/cda/C32_CDA.xsd")
Validation.register_validator :C32, Validators::Schematron::CompiledValidator.new("CCD Schematron Validator","resources/schematron/ccd_errors.xslt")
Validation.register_validator :C32, Validators::Schematron::CompiledValidator.new("C32 Schematron Validator","resources/schematron/c32_v2.1_errors.xslt")
Validation.register_validator :C32, Validators::Umls::UmlsValidator.new("warning")
#Validation.register :C32, Validators::Schematron::SchematronValidator.new

require 'import_helper'
require 'importers/c32/allergy_c32_importer'

require 'active_record_comparator'