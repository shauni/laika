require_dependency 'xml_helper'
require_dependency 'laika/constants'


require 'import_helper'
require 'importers/c32/advance_directive_c32_importer'
require 'importers/c32/allergy_c32_importer'
require 'importers/c32/registration_information_c32_importer'
require 'importers/c32/condition_c32_importer'
require 'importers/c32/medication_c32_importer'
require 'importers/c32/patient_c32_importer'
require 'importers/c32/result_c32_importer'
require 'importers/c32/vital_sign_c32_importer'
require 'importers/c32/support_c32_importer'
require 'importers/c32/insurance_provider_c32_importer'

require 'active_record_comparator'

# Requiring this initializes the validators.
# Validator initialization was moved from here
# into lib/validation.rb to address #104
# See lib/validation.rb comments for details.
require_dependency 'validation'

