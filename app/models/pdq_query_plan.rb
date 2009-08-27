class PdqQueryPlan < PixPdqPlan
  test_name 'PDQ Query'
  pending_actions 'inspect' => :pix_pdq_inspect
  completed_actions 'inspect' => :pix_pdq_inspect
end
