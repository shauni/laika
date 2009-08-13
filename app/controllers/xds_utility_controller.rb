require_dependency 'sort_order'

class XdsUtilityController < ApplicationController
  
  page_title 'XDS Utility'
  
  include SortOrder
  self.valid_sort_fields = %w[ name created_at updated_at ]
   
  def index
      @patients = XdsUtility.all_patients      
   
      
      sort_field = sort_order.split( ' ' ).first
      sort_direction = sort_order.split( ' ' ).second
      
      @patients.sort!{ |a,b|
        val_a = a.patient.andand[ sort_field ] || ""
        val_b = b.patient.andand[ sort_field ] || val_a.class.new
        val_a <=> val_b
      }
      
      if sort_direction == "DESC"
        @patients.reverse!
      end
      
  end
  
end
