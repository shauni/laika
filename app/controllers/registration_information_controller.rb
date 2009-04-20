class RegistrationInformationController < PatientChildController

  def edit
    @registration_information = @patient.registration_information
  end

  def create
    @patient.registration_information = RegistrationInformation.new(params[:registration_information])
    render :partial  => 'show', :locals => {
      :registration_information => @patient.registration_information,
      :patient => @patient
    }
  end

  def update
    @patient.registration_information.update_attributes params[:registration_information]
    render :partial  => 'show', :locals => {
      :registration_information => @patient.registration_information,
      :patient => @patient
    }
  end

  def destroy
    @patient.registration_information.destroy
    render :partial  => 'show', :locals => {:registration_information =>  nil,
                                               :patient => @patient}
  end
  
end
