# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'
require File.expand_path(File.dirname(__FILE__) + '/laika_spec_helper')

ModelFactory.configure do
  default(Setting) do
    name  { |i| "factory setting #{i}" }
    value { |i| "factory value #{i}" }
  end

  default(ContentError) do
    validator { 'factory' }
  end

  default(Patient) do
    name { "Harry Manchester" }
    user { User.factory.create }
  end

  default(InsuranceProvider) do
    insurance_provider_patient {
      InsuranceProviderPatient.factory.create(:insurance_provider => self)
    }
    insurance_provider_subscriber {
      InsuranceProviderSubscriber.factory.create(:insurance_provider => self)
    }
    insurance_provider_guarantor {
      InsuranceProviderGuarantor.factory.create(:insurance_provider => self)
    }
  end

  default(User) do
    email { |i| "factoryuser#{i}@example.com" }
    first_name { "Harry" }
    last_name { "Manchester" }
    password { "secret " }
    password_confirmation { password }
  end

  default(Vendor) do
    public_id { |i| "FACTORYVENDOR#{i}" }
    user { User.factory.create }
  end

  default(TestPlan) do
    patient { Patient.factory.create }
    user { User.factory.create }
    vendor { Vendor.factory.create }
  end

  default(XdsProvideAndRegisterPlan) do
    patient { Patient.factory.create }
    user { User.factory.create }
    vendor { Vendor.factory.create }
    test_type_data { XDS::Metadata.new }
  end

  default(C62InspectionPlan) do
    patient { Patient.factory.create }
    user { User.factory.create }
    vendor { Vendor.factory.create }
    clinical_document { ClinicalDocument.factory.create(:doc_type => 'C62') }
  end

  default(ClinicalDocument) do
    size { 256 }
    filename { 'factory_document' }
  end

end

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  # We do not use test-specific fixtures, so
  # all "fixture" data is actually seed data.
  config.fixture_path = RAILS_ROOT + '/db/fixtures/'
end
