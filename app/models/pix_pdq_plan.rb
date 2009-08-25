class PixPdqPlan < TestPlan
  module Actions
    def pix_pdq_inspect
      @patient = @test_plan.patient
    end
  end
end
