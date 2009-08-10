class XdsUtilityController < ApplicationController
  
  page_title 'XDS Utility'

   
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
      end
      
      
  end
  
end
