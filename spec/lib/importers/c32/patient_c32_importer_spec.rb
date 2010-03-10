require File.dirname(__FILE__) + '/../../../spec_helper'

describe PatientC32Importer do
  before do
    @document = REXML::Document.new(File.new(RAILS_ROOT + '/spec/test_data/joe_smith_complete.xml'))
    @patient = PatientC32Importer.import_c32(@document)
  end
  
  it "should import the correct name and have non nil registration information" do
    @patient.name.should == "Joe Smith"
    @patient.registration_information.should_not be_nil
  end
  
  it "should import non-empty C32 modules" do
    @patient.conditions.should_not be_empty
    @patient.medications.should_not be_empty
  end
  
  it "should not fail on missing modules" do
    @patient.results.should be_empty
  end
  
end