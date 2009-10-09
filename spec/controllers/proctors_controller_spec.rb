require File.dirname(__FILE__) + '/../spec_helper'

describe ProctorsController do
  it "should route POST /proctors" do
    params_from(:post, '/proctors').should == {
      :controller => 'proctors',
      :action => 'create'
    }
  end

  it "should route PUT /proctors/1" do
    params_from(:put, '/proctors/1').should == {
      :controller => 'proctors',
      :action => 'update',
      :id => '1'
    }
  end

  it "should route DELETE /proctors/1" do
    params_from(:delete, '/proctors/1').should == {
      :controller => 'proctors',
      :action => 'destroy',
      :id => '1'
    }
  end

  describe "while logged in" do
    before do
      @user = User.factory.create
      controller.stub!(:current_user).and_return(@user)
    end

    it "should create a proctor" do
      proctor_count = @user.proctors.count
      post :create, :proctor => { :name => 'bob', :email => 'bob@bob.foo'}
      @user.proctors.count.should == proctor_count + 1
    end

    it "should update a proctor" do
      proctor = @user.proctors.create(:name => 'bob', :email => 'bob@bob.foo')
      post :update, :id => proctor.id, :proctor => {:name => 'foo'}
      proctor.reload
      proctor.name.should == 'foo'
    end

    it "should delete a proctor" do
      proctor = @user.proctors.create(:name => 'bob', :email => 'bob@bob.foo')
      delete :destroy, :id => proctor.id
      lambda { proctor.reload }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
end

