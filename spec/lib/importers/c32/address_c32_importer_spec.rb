require File.dirname(__FILE__) + '/../../../spec_helper'

describe AddressC32Importer do
  it "should import an address in a C32 into an ActiveRecord object" do
    document = REXML::Document.new(File.new(RAILS_ROOT + '/spec/test_data/joe_c32.xml'))
    addr_element = REXML::XPath.first(document,"//cda:recordTarget/cda:patientRole/cda:addr", {"cda"=>"urn:hl7-org:v3"})
    address = AddressC32Importer.import(addr_element)
    
    address.street_address_line_one.should == "1600 Rockville Pike"
    address.city.should == "Rockville"
    address.state.should == "MD"
    address.iso_country.code.should == "US"
  end
end