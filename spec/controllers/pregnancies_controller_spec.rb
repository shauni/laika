require File.dirname(__FILE__) + '/../spec_helper'

describe PregnanciesController do
  integrate_views

  before do
    controller.stub!(:current_user).and_return(stub_model User)
  end

  it "should display the edit page" do
    pd = stub_model Patient
    Patient.stub!(:find).and_return(pd)

    get :edit, :patient_id => pd.id.to_s

    assigns[:patient].should == pd
    response.should render_template("pregnancies/edit")
    response.layout.should be_nil
  end

  it "should update patients with pregnancy on" do
    pd = stub_model Patient
    Patient.stub!(:find).and_return(pd)

    pd.should_receive(:pregnant=).with(true)
    pd.should_receive(:save!)

    put :update, :patient_id => pd.id.to_s, :pregnant => 'on'

    assigns[:patient].should == pd
  end

  it "should update patients with pregnancy off" do
    pd = stub_model Patient
    Patient.stub!(:find).and_return(pd)

    pd.should_receive(:pregnant=).with(false)
    pd.should_receive(:save!)

    put :update, :patient_id => pd.id.to_s

    assigns[:patient].should == pd
  end

  it "should update patients with pregnancy nil" do
    pd = stub_model Patient
    Patient.stub!(:find).and_return(pd)

    pd.should_receive(:pregnant=).with(nil)
    pd.should_receive(:save!)

    delete :destroy, :patient_id => pd.id.to_s

    assigns[:patient].should == pd
  end

end
