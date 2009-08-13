# XXX For some reason the C32 display and file class was not autoloading
# with the default name. Also it was only failing in this manner during
# the tests! For whatever reason using a slightly different name seems
# to work around the problem.
module Laika
  TEST_PLAN_TYPES = {
    'C32 Display & File' => DisplayAndFileC32Plan,
    'C32 Generate & Format' => GenerateAndFormatC32Plan,
    'PDQ Query' => PdqQueryPlan,
    'PIX Query' => PixQueryPlan,
    'PIX Feed' => PixFeedPlan,
    'XDS Provide & Register' => XdsProvideAndRegisterPlan,
    'XDS Query & Retrieve' => XdsQueryAndRetrievePlan
  }
end
