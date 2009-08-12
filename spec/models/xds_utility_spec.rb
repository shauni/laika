require File.dirname(__FILE__) + '/../spec_helper'


describe XdsUtility do
  fixtures :xds_documents, :xds_ids, :xds_records
  
  it "should return nothing with a bad XDS id" do
    XdsUtility.find_patient('abc').should be_nil
  end
  
  it "should mock the document retrieval from the registry" do
    XdsUtility.should_receive(:documents).with('111', 'abc').and_return(['1','2','3'])
    XdsUtility.documents('111', 'abc').should == ['1','2','3']
  end
  
  
end