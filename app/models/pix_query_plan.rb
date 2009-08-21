class PixQueryPlan < PixPdqPlan
  test_name 'PIX Query'
  pending_actions 'inspect' => :pix_pdq_inspect
  completed_actions 'inspect' => :pix_pdq_inspect
end
