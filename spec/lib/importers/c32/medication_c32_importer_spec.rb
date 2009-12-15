require File.dirname(__FILE__) + '/../../../spec_helper'

describe MedicationC32Importer do
  it "should import a medication entry in a C32 into an ActiveRecord object" do
    document = REXML::Document.new(File.new(RAILS_ROOT + '/spec/test_data/medications/jenny_medication.xml'))

    section = MedicationC32Importer.section(document)
    meds = MedicationC32Importer.import_entries(section)
    med = meds.first
    
    med.product_coded_display_name.should == "Prednisone"
    med.product_code.should == "312615"
    med.expiration_time.should.eql? Date.civil(2015, 10, 02)
  end
end