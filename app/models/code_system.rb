class CodeSystem < ActiveRecord::Base
  extend RandomFinder
  has_select_options :method_name => :select_options
  has_select_options :method_name => :allergy_select_options, 
    :order => "name DESC",
    :conditions => {
      :code => [ # performs a SQL IN
        '2.16.840.1.113883.6.88',  # RxNorm
        '2.16.840.1.113883.4.9',   # FDA Unique Ingredient ID (UNIII)
      ]
    }
  has_select_options :method_name => :medication_select_options,
    :order => "name DESC",
    :conditions => {
      :code => [ # performs a SQL IN
        '2.16.840.1.113883.6.88',  # RxNorm
        '2.16.840.1.113883.6.69',  # NDC
      ]
    }
end
