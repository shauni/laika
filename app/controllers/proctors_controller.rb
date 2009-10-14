class ProctorsController < ApplicationController
  before_filter :find_proctor, :only => %w[ edit update destroy show ]
  page_title "Laika Test Proctors"

  def index
    @proctors = current_user.proctors
  end

  def update
    @proctor.update_attributes! params[:proctor]
    redirect_to proctors_url
  rescue ActiveRecord::InvalidRecord
    render :action => 'edit'
  end

  def create
    @proctor = current_user.proctors.new params[:proctor]
    @proctor.save!
    redirect_to proctors_url
  rescue ActiveRecord::InvalidRecord
    render :action => 'edit'
  end

  def destroy
    @proctor.destroy
    redirect_to proctors_url
  end

  protected

  def find_proctor
    @proctor = current_user.proctors.find params[:id]
  end
end
