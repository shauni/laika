require File.dirname(__FILE__) + '/../spec_helper'

class MyTestPlan < TestPlan
  test_name 'My Test Plan'
end

describe TestPlan do
  it "should list all test plan names" do
    TestPlan.names.should include('My Test Plan')
  end

  it "should get a test plan type" do
    TestPlan.get('My Test Plan').should == MyTestPlan
  end

  it "should start in pending state" do
    MyTestPlan.new.state.should == 'pending'
  end

  it "should transition from pending to passed" do
    MyTestPlan.new.tap(&:pass).state.should == 'passed'
  end

  it "should transition from pending to failed" do
    MyTestPlan.new.tap(&:fail).state.should == 'failed'
  end
end

