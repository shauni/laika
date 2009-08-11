class XdsUtility < ActiveRecord::Base
  establish_connection :nist_xds
  
  def self.patient_template
  
  end
  
  def self.patients
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
