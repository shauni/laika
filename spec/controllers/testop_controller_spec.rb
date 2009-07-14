require File.dirname(__FILE__) + '/../spec_helper'

describe TestopController do
  it "should route with an url" do
    params_from(:get,
      '/vendor_test_plans/1/testop/xds_provide_and_register/prepare').should ==
    {
      :controller          => 'testop',
      :action              => 'perform_test_operation',
      :test_type           => 'xds_provide_and_register',
      :test_operation      => 'prepare',
      :vendor_test_plan_id => '1'
    }
  end

  it "should route with a hash" do
    route_for(
      :controller          => 'testop',
      :action              => 'perform_test_operation',
      :test_type           => 'xds_provide_and_register',
      :test_operation      => 'prepare',
      :vendor_test_plan_id => '1'
    ).should == '/vendor_test_plans/1/testop/xds_provide_and_register/prepare'
  end

  it "should route with a helper" do
    vtp = VendorTestPlan.factory.create
    testop_path( vtp, TestType.get('XDS Provide and Register'), 'prepare').
      should ==
        "/vendor_test_plans/#{vtp.id}/testop/xds_provide_and_register/prepare"
  end

  describe "test operations" do
    before do
      controller.stub!(:current_user).and_return(mock_model(User, :administrator? => true))
      TestType.register("Foo Bar Baz") do
        execution :prepare
        prepare { |vtp| render :text => 'hi world' }
      end
    end

    it "should execute test type callbacks" do
      get :perform_test_operation,
        :vendor_test_plan_id => VendorTestPlan.factory.create.id,
        :test_type => 'foo_bar_baz', :test_operation => 'prepare'
      response.body.should == "hi world"
    end
  end

end
