require File.dirname(__FILE__) + '/../spec_helper'

describe VendorTestPlansController do

  it "should require login" do
    get :index
    response.should redirect_to('/account/login')
  end

  describe "while logged in" do
    before(:each) do
      @user = stub :user
      controller.stub!(:current_user).and_return(@user)
    end
  
    describe "without test plans" do
      before(:each) do
        VendorTestPlan.stub!(:find).and_return([])
      end
  
      it "should setup display of the dashboard" do
        get :index
        response.should be_success
      end
    end
  
    describe "with test plans" do
      before(:each) do
        @vendor1 = stub :vendor1
        @vendor2 = stub :vendor2
        @vtp1 = stub :plan, :vendor => @vendor1, :validated? => false, :clinical_document=>false
        @vtp2 = stub :plan, :vendor => @vendor2, :validated? => true, :count_errors_and_warnings => [1,2], :clinical_document=>true
        VendorTestPlan.stub!(:find).and_return([ @vtp1, @vtp2 ])
      end
  
      it "should setup display of the dashboard" do
        get :index
        assigns[:vendors].to_set.should == [@vendor1, @vendor2].to_set
        assigns[:errors][@vtp1].should be_nil
        assigns[:warnings][@vtp1].should be_nil
        assigns[:errors][@vtp2].should == 1
        assigns[:warnings][@vtp2].should == 2
        response.should be_success
      end
    end
  end

  describe "with built-in records" do
    fixtures :patients, :vendors, :users, :kinds, :person_names, :addresses
  
    describe "operated by a non-admin" do
      before do
        @current_user = users(:alex_kroman)
        @current_user.roles.clear
        controller.stub!(:current_user).and_return(@current_user)
      end
  
      it "should retain the previous vendor and kind selection" do
        patient = patients(:joe_smith)
        vendor = Vendor.find :first
        kind = Kind.find :first
        controller.send( :last_selected_kind_id=,   nil)
        controller.send( :last_selected_vendor_id=, nil)
  
        post :create, :patient_id => patient.id.to_s, :vendor_test_plan => { :vendor_id => vendor.id.to_s, :kind_id => kind.id.to_s }
  
        controller.send( :last_selected_vendor ).should == vendor
        controller.send( :last_selected_kind   ).should == kind
      end
  
      it "should auto-assign current user" do
        patient = patients(:joe_smith)
        vendor = Vendor.find :first
        kind = Kind.find :first
  
        User.should_not_receive(:find)
  
        post :create, :patient_id => patient.id.to_s, :vendor_test_plan => { :vendor_id => vendor.id.to_s, :kind_id => kind.id.to_s }
      end
  
      it "should not assign selected user" do
        other = users(:rob_dingwell)
        patient = patients(:joe_smith)
        vendor = Vendor.find :first
        kind = Kind.find :first
        old_count = @current_user.vendor_test_plans.count

        post :create, :patient_id => patient.id.to_s, :vendor_test_plan => {:user_id => other.id.to_s, :vendor_id => vendor.id.to_s, :kind_id => kind.id.to_s }

        @current_user.vendor_test_plans(true).count.should == old_count + 1
      end
    end
  
    describe "operated by an admin" do
      before do
        @current_user = users(:alex_kroman)
        @current_user.roles.clear
        @current_user.roles << Role.administrator
        controller.stub!(:current_user).and_return(@current_user)
      end
  
      it "should assign selected user" do
        other = users(:rob_dingwell)
        patient = patients(:joe_smith)
        vendor = Vendor.find :first
        kind = Kind.find :first
        old_count = other.vendor_test_plans.count

        post :create, :patient_id => patient.id.to_s, :vendor_test_plan => {:user_id => other.id.to_s, :vendor_id => vendor.id.to_s, :kind_id => kind.id.to_s }

        other.vendor_test_plans(true).count.should == old_count + 1
      end
    end
  end

end
