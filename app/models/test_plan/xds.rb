class TestPlan::XDS < TestPlan
  serialize :test_plan_data, ::XDS::Metadata
end
