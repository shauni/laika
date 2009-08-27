class C32DisplayAndFilePlan < TestPlan
  test_name "C32 Display and File"
  pending_actions 'xml' => :c32_xml, 'checklist' => :c32_checklist
  manual_inspection

  module Actions
    def c32_xml
      redirect_to patient_path(test_plan.patient, :format => 'xml')
    end

    def c32_checklist
      @patient = test_plan.patient
      render 'test_plans/c32_checklist.xml', :layout => false
    end
  end
end
