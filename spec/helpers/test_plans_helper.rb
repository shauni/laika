require File.dirname(__FILE__) + '/../spec_helper'

describe TestPlansHelper do

  describe "test_plan_results_class" do

    before(:each) do
      @plan = TestPlan.factory.new
    end

    it "should return pass for pending" do
      @plan.pending?.should be_true
      helper.test_plan_results_class(@plan).should == 'pass'
    end

    it "should return pass for passed" do
      @plan.pass
      helper.test_plan_results_class(@plan).should == 'pass'
    end

    it "should return fail otherwise" do
      @plan.fail
      helper.test_plan_results_class(@plan).should == 'fail'
    end

  end 

  describe "test_plan_results_heading" do

    before(:each) do
      @plan = TestPlan.factory.new
    end

    it "should return Assign Result for pending" do
      @plan.pending?.should be_true
      helper.test_plan_results_heading(@plan).should == 'Assign Result'
    end

    it "should return PASS for passed" do
      @plan.pass
      helper.test_plan_results_heading(@plan).should == 'PASS'
    end

    it "should return FAIL otherwise" do
      @plan.fail
      helper.test_plan_results_heading(@plan).should == 'FAIL'
    end

  end
end
