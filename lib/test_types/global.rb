
#
# Global test callbacks
#
# These callbacks are executed for every test type. They're evaluated in the
# context of the current test type. In this context, the read-only accessor
# kind returns the corresponding Kind instance from the database.
#
TestType.global do
  # Assign callback, executed on test_type.assign(opt).
  #
  # This callback MUST return the newly created vendor_test_plan.
  assign do |opt|
    raise 'patient required' if not opt.key?(:patient)
    raise 'user required'    if not opt.key?(:user)
    raise 'vendor required'  if not opt.key?(:vendor)

    patient = opt[:patient].clone
    patient.create_vendor_test_plan(
      :kind   => kind, # test type accessor
      :vendor => opt[:vendor],
      :user   => opt[:user]
    )
    patient.save!
    patient.vendor_test_plan
  end
end

