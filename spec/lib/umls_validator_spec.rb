require File.dirname(__FILE__) + '/../spec_helper'

describe Validators::Umls::UmlsValidator, "Can validate codes/code_systems " do
  before(:each) do 
    @validator = Validators::Umls::UmlsValidator.new("warning")
    @tests = [ 
               {:codesystem=>"",:code=>"", :expected=>true}, # should return true as we dont pass judgment on code systems we dont know about
               {:codesystem=>"2.16.840.1.113883.6.96",:code=>"46120009", :expected=>true},
               {:codesystem=>"2.16.840.1.113883.6.96",:code=>"made up code", :expected=>false},
               {:codesystem=>"2.16.840.1.113883.6.96",:code=>"56018004",:display_name=>'Wheezin' ,:expected=>false},
               {:codesystem=>"2.16.840.1.113883.6.96",:code=>nil, :expected=>true} # cant say a non existant code in a code system is in valid so assume true
    ]
  end
 
  if ActiveRecord::Base::configurations["umls_test"]

    it "Should validate codes in code systems" do 
      valid = true
      @tests.each do |test|
         test_return = @validator.validate_code(test[:codesystem], test[:code], test[:display_name])
         test_valid = (test_return == test[:expected])
         puts "test fail-- #{test.inspect}     -- test returned #{test_return}  expect #{test[:expected]}" if !test_valid
         valid = valid &&  test_valid
      end
      
      valid.should == true
    end


    it "should validate clinical document contents "  do 
      document = REXML::Document.new(File.new(RAILS_ROOT + '/spec/test_data/validators/valid_codes.xml'))
      errors =  @validator.validate(nil,document)
      errors.should be_empty
    end


    it "should not validate clinical document contents with bad codes in known code systems"  do 
      document = REXML::Document.new(File.new(RAILS_ROOT + '/spec/test_data/validators/invalid_codes.xml'))
      errors =  @validator.validate(nil,document)
      errors.should_not be_empty
      #puts errors
    end
      
  end

  it "should provide a configuration_key matching the current environment" do
    Validators::Umls.configuration_key.should == "umls_test"
  end

  describe "with a missing configuration" do

    before do
      @current_configuration = ActiveRecord::Base.configurations[Validators::Umls.configuration_key]
      ActiveRecord::Base.configurations[Validators::Umls.configuration_key] = nil
    end

    after do
      ActiveRecord::Base.configurations[Validators::Umls.configuration_key] = @current_configuration
    end

    it "should be able to determine that we are not configured" do
      Validators::Umls.configured?.should be_false
    end

    it "should handle validation failure do to lack of umls database" do
      document = REXML::Document.new(File.new(RAILS_ROOT + '/spec/test_data/validators/valid_codes.xml'))
      errors =  @validator.validate(nil,document)
      errors.size.should == 1
      errors[0].error_message.should =~ /Laika was not configured to use a UMLS database/
    end
  end

  describe "with a bad configuration" do

    before do
      @current_configuration = ActiveRecord::Base.configurations[Validators::Umls.configuration_key]
      ActiveRecord::Base.configurations[Validators::Umls.configuration_key] = { 
        :adapter   => "jdbcmysql",
        :host      => "localhost",
        :database  => "umls_does_not_exist",
      }
    end

    after do
      ActiveRecord::Base.configurations[Validators::Umls.configuration_key] = @current_configuration
    end

    it "should show that we are configured" do
      Validators::Umls.configured?.should be_true
    end

    it "should fail if attempt to validate" do
      document = REXML::Document.new(File.new(RAILS_ROOT + '/spec/test_data/validators/valid_codes.xml'))
      errors =  @validator.validate(nil,document)
      errors.size.should == 1
      errors[0].error_message.should =~ /Laika encountered an error connecting/
    end
  end

end
