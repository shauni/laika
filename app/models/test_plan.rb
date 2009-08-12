# 
# This is the base type for test plans. To add a new test plan type you must
# subclass TestPlan and declare a name using +test_name+:
#
#  class MyAwesomeTestPlan < TestPlan
#    test_name "My Awesome Test"
#  end
#
# Test plans use an internal state machine to track progress. All test
# plans start out in the +pending+ state. You can use the methods +pass+
# or +fail+ to change the state:
#
#  plan = TestPlan.new
#  plan.state             #=> 'pending'
#  plan.tap(&:pass).state #=> 'passed'
#
# You cannot change the state of a plan once it has passed
# or failed, so you can only pass or fail pending tests.
#
#  plan = TestPlan.new
#  plan.state             #=> 'pending'
#  plan.tap(&:fail).state #=> 'failed'
#
class TestPlan < ActiveRecord::Base
  belongs_to :user
  belongs_to :vendor
  belongs_to :patient,           :dependent => :destroy
  belongs_to :clinical_document, :dependent => :destroy
  before_create :clone_patient

  validates_presence_of :user_id
  validates_presence_of :vendor_id
  validates_presence_of :patient_id
  
  protected

  # Automatically clone the patient record before creating
  # a new test plan.
  def clone_patient
    self.patient = Patient.find(patient_id).clone
  end

  # Accessor for the test plan type registry.
  #
  # @return [Hash] Registered test plan types, keyed by name.
  def self.test_types
    @@test_types ||= {}
  end

  public

  state_machine :initial => :pending do
    event :pass do
      transition :pending => :passed
    end
    event :fail do
      transition :pending => :failed
    end
  end

  # Return the normalized name of this test plan, but with underscores instead
  # of dashes. Useful for building URLs and file paths.
  def parameterized_name
    self.class.normalize_name(self.class.test_name).gsub('-','_')
  end

  # Get a test plan type given a test name.
  #
  # @example
  #  TestPlan.get('XDS Provide and Register') #=> XDSProvideAndRegisterPlan
  #
  # @param [String] name Unambiguous test plan type identifier.
  # @return [Class] The requested test plan type.
  def self.get name
    test_types[normalize_name name]
  end

  # Return the names of all registered test plan types.
  #
  # @example
  #  TestPlan.names #=> [ 'XDS Provide and Register', .., 'C32 Display and File' ]
  #
  # @return [Array<String>] Test plan type names.
  def self.names
    test_types.values.map { |t| t.test_name }
  end

  # Use this in subclasses to declare the name of the test and to register it
  # in the list of test plan types. With no arguments, returns the name of the
  # test.
  #
  # @example
  #  class MyTest < TestPlan
  #    test_name "My Test"
  #  end
  #  MyTest.test_name #=> "My Test"
  #
  # @param [String] Test plan type name.
  def self.test_name name = nil
    if name.nil?
      @test_name
    else
      test_types[normalize_name name] = self
      @test_name = name

    end
  end

  # Normalize the given name for easy comparison.
  #
  # @param [String] name non-normalized name
  # @return [String] normalized name
  def self.normalize_name name
    name.strip.downcase.gsub('_','-').gsub(/\ba?nd?\b|&/i, '-and-').gsub(/\W+/, '-')
  end
end

# Declare test plan types here to make sure they are loaded
# when this class is loaded.
XdsProvideAndRegisterPlan
XdsQueryAndRetrievePlan

