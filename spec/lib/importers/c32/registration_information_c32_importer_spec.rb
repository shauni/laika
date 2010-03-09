require File.dirname(__FILE__) + '/../../../spec_helper'

describe RegistrationInformationC32Importer do
  it "should import a vital sign entry in a C32 into an ActiveRecord object" do
    document = REXML::Document.new(File.new(RAILS_ROOT + '/spec/test_data/joe_c32.xml'))

    section = RegistrationInformationC32Importer.section(document)
    reg_info = RegistrationInformationC32Importer.import_entries(section).first
    
    reg_info.person_name.first_name.should == "Joe"
    reg_info.gender.code.should == "M"
    reg_info.address.city.should == "Rockville"

  end
end