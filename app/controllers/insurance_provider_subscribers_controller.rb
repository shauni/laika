class InsuranceProviderSubscribersController < PatientChildController

  def update
    insurance_provider_subscriber = @patient.insurance_provider_subscribers.find(params[:id])
    insurance_provider_subscriber.update_attributes(params[:insurance_provider_subscriber])

    render :partial  => 'show', :locals => {
      :insurance_provider_subscriber => insurance_provider_subscriber,
      :patient                  => @patient
    }
  end

end
