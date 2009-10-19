require File.dirname(__FILE__) + '/../spec_helper'
describe C62InspectionPlan do
  context "with faked-up C62 sample data" do
    before do
      @c62_doc = <<-EOD
<ClinicalDocument><component><nonXMLBody>
<text mediaType="text/plain" representation="B64">
SGkgd29ybGQhCg==
</text></nonXMLBody></component></ClinicalDocument>
      EOD
      doc = mock(:current_data => @c62_doc)
      @plan = C62InspectionPlan.factory.create
      @plan.stub!(:clinical_document).and_return(doc)
    end

    it "should extract the MIME type" do
      @plan.payload_type.should == "text/plain"
    end

    it "should extract the payload" do
      @plan.payload_data.should == "Hi world!\n"
    end
  end
end

