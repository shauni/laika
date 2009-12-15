require File.dirname(__FILE__) + '/../../../spec_helper'

describe ResultC32Importer do
  it "should import a result entry in a C32 into an ActiveRecord object" do
    document = REXML::Document.new(File.new(RAILS_ROOT + '/spec/test_data/results/jenny_result.xml'))

    section = ResultC32Importer.section(document)
    results = ResultC32Importer.import_entries(section)
    result = results.first
    
    result.result_id.should == "57d07056-bd97-4c90-891d-eb716d3170c8"
    result.result_date.should.eql? Date.civil(2007, 11, 17)
    result.result_code.should == "2093-3"
    result.result_code_display_name.should == "Cholesterol"
    result.status_code.should == "N"
    result.value_scalar.should == "135"
    result.value_unit.should == "md/dL"
  end
end