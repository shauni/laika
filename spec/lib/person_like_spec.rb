require File.dirname(__FILE__) + '/../spec_helper'

describe PersonLike do
  it "should find a PersonLike model with some attributes to not be blank" do
    ri = RegistrationInformation.new
    name = PersonName.new
    name.first_name = 'Andy'
    ri.person_name = name
    ri.person_blank?.should be_false
  end
  
  it "should find a PersonLike model with no attributes to be blank" do
    ri = RegistrationInformation.new
    ri.person_blank?.should be_true
  end
end