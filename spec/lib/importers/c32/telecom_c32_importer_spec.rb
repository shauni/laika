require File.dirname(__FILE__) + '/../../../spec_helper'

describe TelecomC32Importer do
  it "should import a telecom element in a C32 into an ActiveRecord object" do
    document = REXML::Document.new(File.new(RAILS_ROOT + '/spec/test_data/telecom/jenny_telecom_with_uses.xml'))
    tel_container = REXML::XPath.first(document,"//cda:root", {"cda"=>"urn:hl7-org:v3"})
    tel = TelecomC32Importer.import(tel_container)
    
    tel.home_phone.should == "+1-617-555-1212"
    
  end
end