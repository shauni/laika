require File.dirname(__FILE__) + '/../spec_helper'

describe CodeSystem do
  fixtures :code_systems

  it "should provide select options for allergies" do
    CodeSystem.allergy_select_options.should == [
      [code_systems(:rxnorm).name, code_systems(:rxnorm).id],
      [code_systems(:fda_uniii).name, code_systems(:fda_uniii).id],
    ]
  end

  it "should provide select options for medications" do
    CodeSystem.medication_select_options.should == [
      [code_systems(:rxnorm).name, code_systems(:rxnorm).id],
      [code_systems(:ndc).name, code_systems(:ndc).id],
    ]
  end

end
