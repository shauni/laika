class SupportsController < PatientChildController

  def edit
    @support = @patient.support
  end

  def create
    @patient.support = Support.new(params[:support])
    render :partial  => 'show', :locals => {:support =>  @patient.support,
                                            :patient => @patient}
  end

  def update
    @patient.support.update_attributes(params[:support])
    render :partial  => 'show', :locals => {:support =>  @patient.support,
                                            :patient => @patient}
  end

  def destroy
    @patient.support.destroy
    render :partial  => 'show', :locals => {:support =>  nil,
                                            :patient => @patient}
  end
  
end
