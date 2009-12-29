require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do
  it "should route GET /user" do
    params_from(:get, '/user').should == {
      :controller => 'users',
      :action => 'show'
    }
    route_for(
      :controller => 'users',
      :action => 'show'
    ).should == '/user'
  end

  it "should route GET /user/edit" do
    params_from(:get, '/user/edit').should == {
      :controller => 'users',
      :action => 'edit'
    }
    route_for(
      :controller => 'users',
      :action => 'edit'
    ).should == '/user/edit'
  end

  it "should route PUT /user" do
    params_from(:put, '/user').should == {
      :controller => 'users',
      :action => 'update'
    }
  end

  describe "handling GET /user/edit" do

    before(:each) do
      @user = User.factory.create
      controller.stub!(:current_user).and_return(@user)
    end
  
    it "should be successful" do
      get :edit
      response.should be_success
    end
  
    it "should render edit template" do
      get :edit
      response.should render_template('edit')
    end
  
  end

  describe "handling PUT /users/1" do

    before(:each) do
      @user = User.factory.create
      controller.stub!(:current_user).and_return(@user)
    end
    
    describe "with successful update" do

      it "should update the found user" do
        put :update, :user => {:first_name => 'Alex'}
        @user.reload
        @user.first_name.should == 'Alex'
      end

      it "should redirect to the user" do
        put :update, :user => {:first_name => 'Alex'}
        response.should redirect_to(edit_user_url)
      end

    end

    describe "with changing the password" do
        
      it "should update the user" do
        put :update, :user => {:password => '123456', :password_confirmation => '123456'}
        @user.reload
        @user.password.should == '123456'
      end

    end
    
    describe "with failed update" do

      it "should re-render 'edit'" do
        @user.should_receive(:update_attributes).and_return(false)
        put :update
        response.should render_template('edit')
      end

    end

  end

end
