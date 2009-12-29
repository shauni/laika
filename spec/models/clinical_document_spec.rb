require File.dirname(__FILE__) + '/../spec_helper'

describe ClinicalDocument, "can store validation reports" do
  before(:each) do
    @joe = ClinicalDocument.create!(
      :uploaded_data =>
        ActionController::TestUploadedFile.new(
          Rails.root.join('spec/test_data/joe_c32.xml').to_s, 'text/xml')
    )
  end

  it "should be able to obtain document as an REXML::Document " do
     doc = @joe.as_xml_document
     doc.class.should  == REXML::Document
     # the test document has one stylesheet declaration so this should equal 1
     doc.instructions.length.should == 1
     # ask for the doc again with the stylesheet tags stripped out
     doc =  @joe.as_xml_document(true)
     doc.instructions.length.should == 0
  end
end
