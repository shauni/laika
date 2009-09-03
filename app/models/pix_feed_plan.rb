class PixFeedPlan < PixPdqPlan
  test_name 'PIX Feed'
  pending_actions 'Compare>' => :pix_feed_setup
  completed_actions 'Inspect' => :pix_pdq_inspect

  serialize :test_type_data, Hash

  def expected
    PatientIdentifier.new(test_type_data || {})
  end

  module Actions
    def pix_feed_setup
      render :layout => false
    end

    def pix_feed_compare
      @result = PatientIdentifier.new params[:patient_identifier]
      test_plan.update_attributes(:test_type_data => @result.attributes)

      @test_plan.patient.patient_identifiers.each do |pi|
        if pi.patient_identifier == @result.patient_identifier &&
            pi.affinity_domain == @result.affinity_domain
          @test_plan.pass
          break
        end
      end

      unless @test_plan.passed?
        @test_plan.fail
      end

      redirect_to test_plans_url
    end
  end

end
