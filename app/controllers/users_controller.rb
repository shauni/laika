class UsersController < ApplicationController
  page_title 'Laika User Profile'

  def edit
    @user = current_user
    @proctors = current_user.proctors
  end

  def update
    if current_user.update_attributes(params[:user])
      flash[:notice] = "Your settings have been saved."
      redirect_to edit_user_path
    else
      render :action => 'edit'
    end
  end

end
