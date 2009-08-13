require File.dirname(__FILE__) + '/../spec_helper'

describe XdsUtility do
  
  fixtures :patient_identifiers, :patients
  
  before(:each) do
    #prep our comparison
    @patients = []
    @patients << XDSUtils::XDSRecord.new
    @patients[0].documents = ['urn:uuid:265e5f4e-9723-4d34-bfa6-f709cb92abbb']
    @patients[0].id = '1234567890^^^CCHIT&1.2.3.4.5.6.7.8.9&ISO'
    @patients[0].id_scheme = 'urn:uuid:6b5aea1a-874d-4603-a4bc-96a0a7b38446'
    @patients[0].patient = XdsUtility.find_patient( '1234567890^^^CCHIT&1.2.3.4.5.6.7.8.9&ISO' )
  end
  
  it "should return nothing when given a bad XDS id" do
    XdsUtility.find_patient('abc').should be_nil
  end
  
  it "should return the found patient as a Laika model" do
    XdsUtility.find_patient('1234567890^^^CCHIT&1.2.3.4.5.6.7.8.9&ISO').should_not be_nil
  end
  
  it "should return all patients created as an array of XDSRecords" do
    XdsUtility.should_receive(:documents).with(
                                            'urn:uuid:6b5aea1a-874d-4603-a4bc-96a0a7b38446',
                                            '1234567890^^^CCHIT&1.2.3.4.5.6.7.8.9&ISO').and_return(['urn:uuid:265e5f4e-9723-4d34-bfa6-f709cb92abbb'])
    
    XdsUtility.should_receive(:all_identifiers).and_return([{ 'identificationscheme' => 'urn:uuid:6b5aea1a-874d-4603-a4bc-96a0a7b38446',
                                                              'value' => '1234567890^^^CCHIT&1.2.3.4.5.6.7.8.9&ISO'}])                                        
                                            
    #XdsUtility.all_patients.should eql(@patients)    
    ap = XdsUtility.all_patients                
    ap.first.id.should eql(@patients.first.id)
    ap.first.documents.should eql(@patients.first.documents)
    ap.first.id_scheme.should eql(@patients.first.id_scheme)
    ap.first.patient.should eql(@patients.first.patient)
  end
  
  it "should return an empty set of XDSRecords" do
    
    XdsUtility.should_receive(:all_identifiers).and_return( [] )
    ap = XdsUtility.all_patients          
    ap.should eql( [] )  
  end
  
 
  
end