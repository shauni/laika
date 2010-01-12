require 'validators/c32/abstract_result_c32_validation.rb'

module VitalSignC32Validation

  include MatchHelper
  include AbstractResultValidation

  def section_template_id
    '2.16.840.1.113883.10.20.1.16'
  end

end
