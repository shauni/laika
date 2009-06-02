require File.dirname(__FILE__) + '/../spec_helper'

describe TestType, "with an existing test kind" do
  fixtures :users, :registration_information, :patients, :patient_identifiers

  before do
    @vendor = Vendor.create!(:public_id => 'DICT')
    @kind = Kind.create!(:test_type => 'XDS', :name => 'Funk and Wagnall')
  end

  it "should normalize test name" do
    [
      'xds: Provide & Register',
      'XDS provide and register',
      'XDS: Provide and   Register',
      "XDS Provide-and-Register\n",
      "xds provide n register",
      "xDs provide -n- register",
      "xdS provide   an register",
      "Xds provide nd register",
      "  Xds provide and register",
      "XDS provide and register   ",
      "XDS PROVIDE AND REGISTER",
    ].map { |type_name|
      TestType.send(:normalize_name, type_name)
    }.to_set.size.should == 1
  end

  describe "with a registered type, no callbacks" do
    before do
      TestType.register(@kind.display_name)
      @test_type = TestType.get(@kind.display_name)
    end

    it "should get() using a denormalized name" do
      TestType.get('xds funk & wagnall').should == @test_type
    end

    it "should assign a new test plan" do
      old_count = VendorTestPlan.count
      @test_type.assign(
        :vendor  => @vendor,
        :patient => Patient.find(:first),
        :user    => User.find(:first)
      )
      VendorTestPlan.count.should == old_count + 1
    end

    it "should return a newly created test plan" do
      patient = Patient.find(:first)
      user    = User.find(:first)
      vtp = @test_type.assign(
        :vendor  => @vendor,
        :patient => patient,
        :user    => user
      )
      vtp.should_not be_nil
      vtp.vendor.should == @vendor
      vtp.user.should == user
      vtp.patient.should_not == patient # remember, it's cloned
      vtp.patient.patient_identifier.should == patient.patient_identifier
    end
  end

  describe "with a registered type, error during assign" do
    before do
      TestType.register(@kind.display_name) do
        assign { |vtp| raise 'omg' }
      end
      @test_type = TestType.get(@kind.display_name)
    end

    it "should raise TestType::AssignError on assign" do
      lambda {
        @test_type.assign(
          :vendor  => @vendor,
          :patient => Patient.find(:first),
          :user    => User.find(:first)
        )
      }.should raise_error(TestType::AssignFailure)
    end
  end

  describe "with a registered type that wants context" do
    before do
      class ContextTester
        def yay; @yay = true; end
        def yay_called?; @yay; end
      end
      TestType.register(@kind.display_name) do
        assign { |vtp| yay }
      end
      @test_type = TestType.get(@kind.display_name)
    end

    it "should use with_context to set context" do
      context = ContextTester.new
      wrapper = @test_type.with_context(context)
      wrapper.assign(
        :vendor  => @vendor,
        :patient => Patient.find(:first),
        :user    => User.find(:first)
      )
      context.yay_called?.should be_true
    end

    it "should pass context on assign" do
      context = ContextTester.new
      @test_type.assign(
        :vendor  => @vendor,
        :patient => Patient.find(:first),
        :user    => User.find(:first),
        :cb_context => context
      )
      context.yay_called?.should be_true
    end
  end
end

