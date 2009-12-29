class C62InspectionPlan < TestPlan
  test_name "C62 Inspection"
  pending_actions 'Payload' => :c62_payload
  completed_actions 'Payload' => :c62_payload
  manual_inspection

  # Requires a C62 document attachment
  accepts_nested_attributes_for :clinical_document
  validates_presence_of :clinical_document

  private

  def document
    @document ||= Validators::C62::Reader.new(clinical_document.current_data)
  end

  public

  def payload_type
    document.payload_type
  end

  def payload_data
    document.payload_data
  end

  module Actions
    def c62_payload
      render :type => test_plan.payload_type, :text => test_plan.payload_data
    end
  end
end
