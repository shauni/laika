class C62InspectionPlan < TestPlan
  test_name "C62 Inspection"
  pending_actions 'Payload' => :c62_payload
  completed_actions 'Payload' => :c62_payload
  manual_inspection

  # Requires a C62 document attachment
  accepts_nested_attributes_for :clinical_document
  validates_presence_of :clinical_document

  private

  def payload_element
    @elements ||= REXML::Document.new(clinical_document.current_data).elements
    @elements['ClinicalDocument/component/nonXMLBody/text']
  end

  public

  def payload_type
    payload_element.attributes['mediaType'] if payload_element
  end

  def payload_data
    Base64.decode64(payload_element.text) if payload_element
  end

  module Actions
    def c62_payload
      render :type => test_plan.payload_type, :text => test_plan.payload_data
    end
  end
end
