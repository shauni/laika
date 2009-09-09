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

    it "should forward to the current vendor" do
      @controller.send(:last_selected_vendor_id=, @vendor.id)
      get :index
      response.should redirect_to(vendor_test_plans_url(@vendor))
    end

    describe "with a C32 Generate and Format plan" do
      before do
        @plan = C32GenerateAndFormatPlan.factory.create(:user => @user)
      end

      it "should prompt for an XML document upload" do
        get :c32_upload, :id => @plan.id
        assigns(:test_plan).should == @plan
        response.should render_template('test_plans/c32_upload')
      end

      it "should validate the test case" do
        validator = stub(:validator)
        validator.stub!(:contains_kind_of?).and_return(false)
        validator.stub!(:validate).and_return([])
        Validation.stub!(:get_validator).and_return(validator)

        get :c32_validate, :id => @plan.id,
          :clinical_document => {
            :uploaded_data => fixture_file_upload('../test_data/joe_c32.xml')
          }
        @plan.reload
        @plan.should be_passed
      end

      it "should display inspection results" do
        get :c32_inspect, :id => @plan.id
        assigns(:test_plan).should == @plan
        response.should render_template('test_plans/c32_inspect.html.erb')
      end

    end

    describe "with a XDS Provide and Register plan" do
      before do
        @plan = XdsProvideAndRegisterPlan.factory.create(:user => @user)
      end

      it "should prompt for XDS document selection" do
        TestPlan.stub!(:find).and_return(@plan)
        metadata = [XDS::Metadata.new]
        @plan.should_receive(:fetch_xds_metadata).and_return(metadata)

        get :xds_select_document, :id => @plan.id
        assigns(:metadata).should == metadata
      end

      it "should compare metadata" do
        TestPlan.stub!(:find).and_return(@plan)
        @plan.should_receive(:validate_xds_metadata).with(:a => 'b')
        get :xds_compare, :id => @plan.id, :test_type_data => "---\n:a: b\n"
      end
    end

    describe "with a PIX Feed plan" do
      before do
        @plan = PixFeedPlan.factory.create(:user => @user)
      end

      it "should request additional data" do
        get :pix_feed_setup, :id => @plan.id
        response.should be_success
        response.should render_template('test_plans/pix_feed_setup.html.erb')
      end

      it "should compare results and fail" do
        post :pix_feed_compare, :id => @plan.id,
          :patient_identifier => {
            :patient_identifier => 'foo',
            :affinity_domain => 'bar'
          }
        @plan.reload
        @plan.should be_failed
      end

      it "should compare results and pass" do
        pi = { :patient_identifier => 'foo', :affinity_domain => 'bar' }
        @plan.patient.patient_identifiers << PatientIdentifier.new(pi)
        post :pix_feed_compare, :id => @plan.id, :patient_identifier => pi
        @plan.reload
        @plan.should be_passed
      end
    end

    describe "with test-specific plans" do
      before(:all) do
        Laika::TEST_PLAN_TYPES['My Complex Test'] = MyComplexTestPlan
        Laika::TEST_PLAN_TYPES['My Simple Test'] = MySimpleTestPlan
      end
      after(:all) do
        Laika::TEST_PLAN_TYPES.delete 'My Complex Test'
        Laika::TEST_PLAN_TYPES.delete 'My Simple Test'
      end

      it "should display tests for the specified vendor" do
        plan = MySimpleTestPlan.create \
          :user_id => @user.id.to_s,
          :vendor_id => @vendor.id.to_s
        get :index, :vendor_id => @vendor.id
        assigns(:test_plans).to_a.should == [ plan ]
        assigns(:vendor).should == @vendor
        assigns(:other_vendors).should == []
      end

      it "should assign a simple test" do
        old_count = TestPlan.count
        post :create, :test_plan => {
            :type => 'MySimpleTestPlan',
            :user_id => @user.id.to_s,
            :vendor_id => @vendor.id.to_s
          }, :patient_id => @patient.id.to_s
        TestPlan.count.should == old_count + 1
      end

      it "should request more info for a complex test" do
        old_count = TestPlan.count
        post :create, :test_plan => {
            :type => 'MyComplexTestPlan',
            :user_id => @user.id.to_s,
            :vendor_id => @vendor.id.to_s
          }, :patient_id => @patient.id.to_s
        TestPlan.count.should == old_count
      end
    end
  end
end
