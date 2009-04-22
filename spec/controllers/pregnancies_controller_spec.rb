require File.dirname(__FILE__) + '/../spec_helper'

describe PregnanciesController do
  integrate_views
  fixtures :patients

  before do
    controller.stub!(:current_user).and_return(stub_model User)
  end

  it "should display the edit page" do
    pd = Patient.first

    get :edit, :patient_id => pd.id.to_s

    assigns[:patient].should == pd
    response.should render_template("pregnancies/edit")
    response.layout.should be_nil
  end

  it "should update patients with pregnancy on" do
    pd = Patient.first

    put :update, :patient_id => pd.id.to_s, :pregnant => 'on'

    pd.reload
    pd.pregnant.should == true
  end

  it "should update patients with pregnancy off" do
    pd = Patient.first

    put :update, :patient_id => pd.id.to_s

    pd.reload
    pd.pregnant.should == false
  end

  it "should update patients with pregnancy nil" do
    pd = Patient.first

    delete :destroy, :patient_id => pd.id.to_s

    pd.reload
    pd.pregnant.should be_nil
  end

end
