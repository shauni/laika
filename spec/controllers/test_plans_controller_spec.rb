require File.dirname(__FILE__) + '/../spec_helper'

class MySimpleTestPlan < TestPlan
  test_name "My Simple Test"
end
class MyComplexTestPlan < TestPlan
  test_name "My Complex Test"
  validates_presence_of :test_plan_data
end

describe TestPlansController do
  describe "while logged in" do
    before do
      @user = User.factory.create
      @vendor = Vendor.factory.create(:user => @user)
      @patient = Patient.factory.create
      @controller.stub(:current_user).and_return(@user)
    end

    it "should display tests for the current vendor" do
      @controller.send(:last_selected_vendor_id=, @vendor.id)
      plan = MySimpleTestPlan.create \
        :patient_id => @patient.id.to_s,
        :user_id => @user.id.to_s,
        :vendor_id => @vendor.id.to_s
      get :index
      assigns(:test_plans).to_a.should == [ plan ]
      assigns(:vendor).should == @vendor
      assigns(:other_vendors).should == []
    end

    it "should assign a simple test" do
      old_count = TestPlan.count
      post :create, :test_plan => {
        :type => 'My Simple Test',
        :patient_id => @patient.id.to_s,
        :user_id => @user.id.to_s,
        :vendor_id => @vendor.id.to_s
      }
      TestPlan.count.should == old_count + 1
    end

    it "should request more info for a complex test" do
      old_count = TestPlan.count
      post :create, :test_plan => {
        :type => 'My Complex Test',
        :patient_id => @patient.id.to_s,
        :user_id => @user.id.to_s,
        :vendor_id => @vendor.id.to_s
      }
      TestPlan.count.should == old_count
    end
  end
end
