require File.dirname(__FILE__) + '/../spec_helper'

describe Encounter, "can generate random values for itself" do
  it 'should create a valid Encounter when randomized' do
    encounter = Encounter.new
    encounter.randomize(Date.parse('1978-06-05'))
    
    encounter.encounter_date.should_not be_nil
    encounter.person_name.should_not be_nil
    encounter.telecom.should_not be_nil
    encounter.address.should_not be_nil
    encounter.encounter_id.should_not be_nil    
  end
end