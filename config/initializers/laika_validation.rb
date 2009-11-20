require_dependency 'xml_helper'
require_dependency 'laika/constants'

# Requiring this initializes the validators.
# Validator initialization was moved from here
# into lib/validation.rb to address #104
# See lib/validation.rb comments for details.
require_dependency 'validation'
