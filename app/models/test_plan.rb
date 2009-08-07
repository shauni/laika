# 
# This is the base type for test plans. To add a new test plan type you must
# subclass TestPlan and declare a name using +test_name+:
#
#  class MyAwesomeTestPlan < TestPlan
#    test_name "My Awesome Test"
#  end
#
class TestPlan < ActiveRecord::Base

  private

  # Accessor for the test plan type registry.
  #
  # @return [Hash] Registered test plan types, keyed by name.
  def self.test_types
    @@test_types ||= {}
  end

  public

  # Get a test plan type given a test name.
  #
  # @example
  #  TestPlan.get('XDS Provide and Register') #=> TestPlan::XDS::ProvideAndRegister
  #
  # @param [String] name Unambiguous test plan type identifier.
  # @return [Class] The requested test plan type.
  def self.get name
    test_types[name]
  end

  # Return the names of all registered test plan types.
  #
  # @example
  #  TestPlan.names #=> [ 'XDS Provide and Register', .., 'C32 Display and File' ]
  #
  # @return [Array<String>] Test plan type names.
  def self.names
    test_types.keys
  end

  # Use this in subclasses to declare the name of the test and to register it
  # in the list of test plan types.
  #
  # @example
  #  class MyTest < TestPlan
  #    test_name "My Test"
  #  end
  #
  # @param [String] Test plan type name.
  def self.test_name name
    test_types[name] = self
    @test_name = name
  end

  state_machine :initial => :pending do
    event :pass do
      transition :pending => :passed
    end
    event :fail do
      transition :pending => :failed
    end
  end
end

# Whenever this file is reloaded it will cause the index of available test
# types to be reset. To avoid this the child test plan types must be reloaded
# as well.
Dir[File.dirname(__FILE__) + '/test_plan/**/*.rb'].each { |f| load f }

