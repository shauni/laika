class SupportsController < PatientChildController

  def edit
    @support = @patient.support
  end

  def create
    support = Support.new(params[:support])
    @patient.support = support
    render :partial  => 'show', :locals => {:support =>  support,
                                            :patient => @patient}
  end

  def update
    support = @patient.support
    support.update_attributes(params[:support])
    render :partial  => 'show', :locals => {:support =>  support,
                                            :patient => @patient}
  end

  def destroy
    @patient.support.destroy
    render :partial  => 'show', :locals => {:support =>  nil,
                                            :patient => @patient}
  end
  
end
