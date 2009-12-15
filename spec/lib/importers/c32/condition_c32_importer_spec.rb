require File.dirname(__FILE__) + '/../../../spec_helper'

describe ConditionC32Importer do
  it "should import a condition entry in a C32 into an ActiveRecord object" do
    document = REXML::Document.new(File.new(RAILS_ROOT + '/spec/test_data/conditions/joes_condition.xml'))

    section = ConditionC32Importer.section(document)
    conditions = ConditionC32Importer.import_entries(section)
    condition = condition.first
    
    condition.start_event.should.eql? Date.civil(2006, 02, 21)
    condition.problem_name.should == "Abnormal mass finding"
  end
end