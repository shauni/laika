class XdsUtility < ActiveRecord::Base
  establish_connection :nist_xds
  
  def self.patients
    
    patients = []
    
    all_identifiers.each do |identifier|
     
      xds_record = XDSUtils::XDSRecord.new
      xds_record.documents = documents(  identifier[ 'identificationscheme' ], identifier['value'] )
      xds_record.id = identifier['value']
      
      split_id = identifier[ 'value' ].split('^^^')
      patient_id = PatientIdentifier.find( :first, 
          :conditions => {  :patient_identifier => split_id.first, 
                            :affinity_domain => split_id.second }
       ).andand.patient_id
      xds_record.patient = Patient.find( patient_id ) unless patient_id.nil?
      
      patients << xds_record
    end
    
    patients
    
  end
  

  
  private
  
  def self.all_identifiers
      xds_all_ids = "SELECT patId.value, patId.identificationScheme FROM ExternalIdentifier patId"
      begin
        connection.select_all( "#{xds_all_ids}\n" )
      rescue ActiveRecord::StatementInvalid
         flash[:notice] = "Could not find any patients."
         return
      end
  end
  
  def self.documents( id_scheme, id )
    
    xds_docs = "SELECT doc.id
                FROM ExtrinsicObject doc, ExternalIdentifier patId
                WHERE
                  doc.id = patId.registryobject AND      
                  patId.identificationScheme='#{id_scheme}'
                AND
                  patId.value = '#{id}';" 
    begin
      connection.select_values( "#{xds_docs}\n" )
    rescue ActiveRecord::StatementInvalid
      flash[:notice] = "Could not find documents associated with that record."
      return 
    end  
  end
end
