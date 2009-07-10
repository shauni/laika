
TestType.shared("PIX/PDQ") do
  execution :checklist
  checklist do |vendor_test_plan|
    @vendor_test_plan = vendor_test_plan
    @patient = vendor_test_plan.patient
    render 'testop/pix_pdq/checklist'
  end
end

TestType.register("PDQ Query") do
  include_shared "PIX/PDQ"
end

TestType.register("PIX Query") do
  include_shared "PIX/PDQ"
end

TestType.register("PIX Feed") do
  execution :gather_expected, :compare, :inspect

  gather_expected do |vendor_test_plan|
    @vendor_test_plan = vendor_test_plan
    render 'testop/pix_feed/gather_expected', :layout => false
  end

  compare do |vendor_test_plan|
    @vendor_test_plan = vendor_test_plan
    @test_result = TestResult.new(params[:test_result])

    @vendor_test_plan.patient.patient_identifiers.each do |pi|
      if pi.patient_identifier == @test_result.patient_identifier &&
          pi.affinity_domain == @test_result.assigning_authority
        @test_result.result = 'PASS'
        break
      end
    end

    @vendor_test_plan.test_result = @test_result
  end

  inspect do |vendor_test_plan|
    @vendor_test_plan = vendor_test_plan
    @patient = vendor_test_plan.patient
    render 'testop/pix_pdq/checklist'
  end
end

