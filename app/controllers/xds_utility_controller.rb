require_dependency 'sort_order'

class XdsUtilityController < ApplicationController
  
  page_title 'XDS Utility'
  
  include SortOrder
  self.valid_sort_fields = %w[ name created_at updated_at ]
   
  def index
      @patients = XdsUtility.all_patients
  end
  
end
