class ConditionsController < PatientChildrenController
  auto_complete_for :snowmed_problem, :name
  skip_before_filter :find_patient, :only => :auto_complete_for_snowmed_problem_name
end
