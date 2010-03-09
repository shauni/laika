require File.dirname(__FILE__) + '/../../../spec_helper'

describe HealthcareProviderC32Importer do
  it "should import an healthcare provider in a C32 into an ActiveRecord object" do
    document = REXML::Document.new(File.new(RAILS_ROOT + '/spec/test_data/jenny_healthcare_provider.xml'))

    section = HealthcareProviderC32Importer.section(document)
    providers = HealthcareProviderC32Importer.import_entries(section)
    hcp = providers.first
    
    hcp.person_name.first_name.should == "Mary"
    hcp.start_service.should.eql? Date.civil(1965, 1, 20)
    hcp.patient_identifier.should == "78A150ED-B890-49dc-B716-5EC0027B3985"

  end
end