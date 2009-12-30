require File.dirname(__FILE__) + '/../../../spec_helper'

describe AdvanceDirectiveC32Importer do
  it "should import an advance directive entry in a C32 into an ActiveRecord object" do
    document = REXML::Document.new(File.new(RAILS_ROOT + '/spec/test_data/advance_directive/jenny_advance_directive.xml'))

    section = AdvanceDirectiveC32Importer.section(document)
    directives = AdvanceDirectiveC32Importer.import_entries(section)
    ad = directives.first
    
    ad.free_text.should == "Do not put on life support"

  end
end