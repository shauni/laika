class XdsUtility < ActiveRecord::Base
  establish_connection :nist_xds_registry
  
  
  #instantiate all identifiers in the registry as XDSRecords
  def self.all_patients
    
    patients = []
    
    all_identifiers.each do |identifier|
     
      xds_record = XDSUtils::XDSRecord.new
      xds_record.documents = documents(  identifier[ 'identificationscheme' ], identifier['value'] )
      xds_record.value = identifier['value']
      xds_record.id = identifier['id']
      xds_record.id_scheme = identifier[ 'identificationscheme' ]
      xds_record.patient = Patient.find_by_patient_identifier( identifier[ 'value' ] )
      
      patients << xds_record
    end
    
    patients
    
  end
  

  
  
  #get all identifiers in the registry
  def self.all_identifiers
      xds_all_ids_query = "SELECT patId.value, patId.identificationScheme, patId.id FROM ExternalIdentifier patId"
      begin
        connection.select_all( "#{xds_all_ids_query}\n" )
      rescue ActiveRecord::StatementInvalid
         flash[:notice] = "Could not find any patients."
         return
      end
  end
  
  #get documents/object ids associated with an identifier in the registry
  def self.documents( id_scheme, value )
    
    xds_docs_query = "SELECT doc.id
                FROM ExtrinsicObject doc, ExternalIdentifier patId
                WHERE
                  doc.id = patId.registryobject AND      
                  patId.identificationScheme='#{id_scheme}'
                AND
                  patId.value = '#{value}';" 
    begin
      connection.select_values( "#{xds_docs_query}\n" )
    rescue ActiveRecord::StatementInvalid
      flash[:notice] = "Could not find documents associated with that record."
      return 
    end  
  end
  
end
