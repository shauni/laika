class XdsQueryAndRetrievePlan < XdsPlan
  test_name "XDS Query & Retrieve"
  manual_inspection
  pending_actions 'query checklist' => :xds_checklist,
    'document checklist' => :c32_checklist
end
