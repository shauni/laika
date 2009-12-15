require File.dirname(__FILE__) + '/../../../spec_helper'

describe VitalSignC32Importer do
  it "should import a vital sign entry in a C32 into an ActiveRecord object" do
    document = REXML::Document.new(File.new(RAILS_ROOT + '/spec/test_data/vital_signa/jenny_vital_sign.xml'))

    section = VitalSignC32Importer.section(document)
    vitals = VitalSignC32Importer.import_entries(section)
    vital = vitals.first
    
    vital.result_id.should == "33d07056-bd27-4c90-891d-eb716d3170c4"
    vital.result_date.should.eql? Date.civil(2007, 11, 17)
    vital.result_code.should == "3141-9"
    vital.result_code_display_name.should == "Body Weight (Measured)"
    vital.status_code.should == "N"
    vital.value_scalar.should == "155"
    vital.value_unit.should == "lbs"
  end
end