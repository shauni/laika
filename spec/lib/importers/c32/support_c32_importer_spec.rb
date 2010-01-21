require File.dirname(__FILE__) + '/../../../spec_helper'

describe SupportC32Importer do
  it "should import a support entry in a C32 into an ActiveRecord object" do
    document = REXML::Document.new(File.new(RAILS_ROOT + '/spec/test_data/supports/jenny_support.xml'))

    section = SupportC32Importer.section(document)
    supports = SupportC32Importer.import_entries(section)
    support = supports.first
    
    support.start_support.should.eql? Date.civil(1975, 8, 27)
    support.end_support.should.eql? Date.civil(2030, 1, 9)

  end
end