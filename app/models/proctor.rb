# The test proctor is an individual that oversees the testing process but
# does not actually operate the Laika instance. A proctor can be selected
# during test assignment, but is not required.
class Proctor < ActiveRecord::Base
  validates_presence_of :user_id, :name, :email
  belongs_to :user
  has_many :test_plans

  def to_s
    name
  end
end
