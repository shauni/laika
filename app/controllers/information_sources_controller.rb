class InformationSourcesController < PatientChildController

  def edit
    @information_source = @patient.information_source
  end

  def create
    @patient.information_source = InformationSource.new(params[:information_source])
    render :partial  => 'show', :locals => {:information_source => @patient.information_source,
                                            :patient => @patient}
  end

  def update
    @patient.information_source.update_attributes(params[:information_source])
    render :partial  => 'show', :locals => {:information_source => @patient.information_source,
                                            :patient => @patient}
  end

  def destroy
    @patient.information_source.destroy
    render :partial  => 'show', :locals => {:information_source => nil,
                                 :patient => @patient}
  end
end
