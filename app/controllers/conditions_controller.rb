class ConditionsController < PatientChildrenController
  auto_complete_for :snowmed_problem, :name
end
