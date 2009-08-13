# 
# This is the base type for test plans. To add a new test plan type you must
# subclass TestPlan and declare a name using +test_name+:
#
#  class MyAwesomeTestPlan < TestPlan
#    test_name "My Awesome Test"
#  end
#
# To use the test plan you need to add it to the global list:
#
#  Laika::TEST_PLAN_TYPES[MyAwesomeTestPlan.test_name] = MyAwesomeTestPlan
#
# This list is initialized in config/initializers/load_test_plan_types.rb.
# If you want to add a new test plan type to Laika you should add it there.
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
  has_many   :content_errors,    :dependent => :destroy

  before_create :clone_patient
  default_scope :order => 'created_at ASC'

  validates_presence_of :user_id
  validates_presence_of :vendor_id
  validates_presence_of :patient_id

  protected

  # Automatically clone the patient record before creating
  # a new test plan.
  def clone_patient
    self.patient = Patient.find(patient_id).clone
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

  # Accessor for the test plan type registry.
  #
  # @return [Array] Registered test plan types.
  def self.test_types
    Laika::TEST_PLAN_TYPES
  end

  def self.test_name name = nil
    if name.nil?
      @test_name
    else
      @test_name = name
    end
  end

  def self.test_actions actions = nil
    if actions.nil?
      @test_actions ||= {}
    else
      @test_actions = actions
    end
  end

  def test_actions
    self.class.test_actions
  end

  # Normalize the given name for easy comparison.
  #
  # @param [String] name non-normalized name
  # @return [String] normalized name
  def self.normalize_name name
    name.strip.downcase.gsub('_','-').gsub(/\ba?nd?\b|&/i, '-and-').gsub(/\W+/, '-')
  end
end


