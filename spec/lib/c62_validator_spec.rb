require File.dirname(__FILE__) + '/../spec_helper'

describe Validators::C62::Validator do
  before do
    xml = <<-END_C62
<ClinicalDocument>
<templateId root="1.3.6.1.4.1.19376.1.2.20"/>
<id root="1.3.4.2.5.2.3.4.2"/>
<title>My Clinical Document</title>
<code code="foo" codeSystem="bar"/>
<confidentialityCode code="foo" codeSystem="bar"/>
<effectiveTime value="2009-10-28 00:00:00 -0800"/>
<languageCode code="en-US"/>
<component><nonXMLBody>
<text mediaType="text/plain" representation="B64">
SGkgd29ybGQhCg==
</text></nonXMLBody></component>
</ClinicalDocument>
    END_C62
    @doc = REXML::Document.new xml
    @patient = Patient.factory.create
    @validator = Validators::C62::Validator.new
  end

  it "should pass a 'quote' valid 'unquote' C62" do
    @validator.validate(@patient, @doc).should be_empty
  end

  it "should require the correct template ID" do
    @doc.elements['ClinicalDocument/templateId'].attributes['root'] = 'foobar'
    @validator.validate(@patient, @doc).should_not be_empty
  end

  it "should require the correct media type" do
    @doc.elements['ClinicalDocument/component/nonXMLBody/text'].
      attributes['mediaType'] = 'foobar'
    @validator.validate(@patient, @doc).should_not be_empty
  end

  it "should require the correct representation" do
    @doc.elements['ClinicalDocument/component/nonXMLBody/text'].
      attributes['representation'] = 'foobar'
    @validator.validate(@patient, @doc).should_not be_empty
  end

  %w[
    ClinicalDocument/id
    ClinicalDocument/templateId
    ClinicalDocument/effectiveTime
    ClinicalDocument/code
    ClinicalDocument/confidentialityCode
    ClinicalDocument/languageCode
    ClinicalDocument/component/nonXMLBody/text
  ].each do |xpath|
    it "should require element #{xpath}" do
      @doc.elements.delete xpath
      @validator.validate(@patient, @doc).should_not be_empty
    end
  end

  %w[
    ClinicalDocument/id@root
    ClinicalDocument/templateId@root
    ClinicalDocument/code@code
    ClinicalDocument/code@codeSystem
    ClinicalDocument/confidentialityCode@code
    ClinicalDocument/confidentialityCode@codeSystem
    ClinicalDocument/effectiveTime@value
    ClinicalDocument/component/nonXMLBody/text@mediaType
    ClinicalDocument/component/nonXMLBody/text@representation
    ClinicalDocument/languageCode@code
  ].map {|a| a.split(/@/, 2) }.each do |element, attribute|
    it "should require attribute #{element}@#{attribute}" do
      @doc.elements[element].attributes.delete(attribute)
      @validator.validate(@patient, @doc).should_not be_empty
    end
  end
end
