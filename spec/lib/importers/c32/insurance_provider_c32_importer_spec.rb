require File.dirname(__FILE__) + '/../../../spec_helper'

describe InsuranceProviderC32Importer do
  it "should import an insurance provider entry in a C32 into an ActiveRecord object" do
    document = REXML::Document.new(File.new(RAILS_ROOT + '/spec/test_data/allergies/joe_allergy.xml'))

    section = InsuranceProviderC32Importer.section(document)
    providers = InsuranceProviderC32Importer.import_entries(section)
    ip = providers.first
    
    ip.represented_organization.should == "Blue Cross Blue Shield"
    ip.group_number.should == "2844AF96-37D5-42a8-9FE3-3995C110B4F8"
  end
end