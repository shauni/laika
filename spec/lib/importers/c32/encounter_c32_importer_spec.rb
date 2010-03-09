require File.dirname(__FILE__) + '/../../../spec_helper'

describe EncounterC32Importer do
  it "should import an encounter entry in a C32 into an ActiveRecord object" do
    document = REXML::Document.new(File.new(RAILS_ROOT + '/spec/test_data/encounters/lacey_encounters.xml'))

    section = EncounterC32Importer.section(document)
    encounters = EncounterC32Importer.import_entries(section)
    e = encounters.first
    
    e.person_name.first_name.should == "Bessie"
    e.encounter_date.should.eql? Date.civil(1998, 1, 11)

  end
end