require_dependency 'sort_order'

class XdsUtilityController < ApplicationController
  
  page_title 'XDS Utility'
  
  include SortOrder
  self.valid_sort_fields = %w[ name created_at updated_at ]
   
  def index
      @patients = XdsUtility.patients
      @laika_patients = {}
      
      @documents = {}
      
  
  
      @patients.each do |patient|
        
          if @documents[ patient ].nil? 
            @documents[ patient ] = []
          end
          
          documents = XdsUtility.documents( patient[ 'identificationscheme' ], patient['value'] )
          @documents[ patient ].push( documents ) unless documents.empty?
          
          #split_id = patient[ 'value' ].split('^^^')
          #patient_id = PatientIdentifier.find( :first, 
          #  :conditions => {  :patient_identifier => split_id.first, 
          #                    :affinity_domain => split_id.second }
         # )
        
         # p = Patient.find( patient_id.patient_id) unless patient_id.nil?
         # @laika_patients[ patient ] = p
          
      end
      
      patient_ids = []
      @patients.each do |patient|
        split_id = patient[ 'value' ].split('^^^')
        patient_id = PatientIdentifier.find( :first, 
          :conditions => {  :patient_identifier => split_id.first, 
                            :affinity_domain => split_id.second }
        ).andand.patient_id
        
        @laika_patients[ patient ] = Patient.find( patient_id ) unless patient_id.nil?
      end
      
      #@laika_patients = Patient.find( patient_ids )
      
      
  end
  
end
