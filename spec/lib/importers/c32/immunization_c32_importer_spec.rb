require File.dirname(__FILE__) + '/../../../spec_helper'

describe ImmunizationC32Importer do
  it "should import an immunization entry in a C32 into an ActiveRecord object" do
    document = REXML::Document.new(File.new(RAILS_ROOT + '/spec/test_data/immunizations/lacey_immunizations.xml'))

    section = ImmunizationC32Importer.section(document)
    immunizations = ImmunizationC32Importer.import_entries(section)
    immunization = immunizations.first
    
    immunization.administration_date.should.eql? Date.civil(1980, 5, 12)
    immunization.vaccine.code.should == "111"

  end
end