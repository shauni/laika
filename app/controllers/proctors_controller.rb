class ProctorsController < ApplicationController
  layout false

  def edit
  end

  def show
  end

  def update
    @proctor = Proctor.find params[:id]
    @proctor.update_attributes!(params[:proctor])
    render :action => 'show'
  rescue ActiveRecord::InvalidRecord
    render :action => 'edit'
  end

  def create
    @proctor = current_user.proctors.new params[:proctor]
    @proctor.save!
    render :action => 'show'
  rescue ActiveRecord::InvalidRecord
    render :action => 'edit'
  end

  def destroy
    proctor = current_user.proctors.find params[:id]
    proctor.destroy
    redirect_to user_url
  end
end
