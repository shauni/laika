class AddStatusOverrideReasonToTestPlan < ActiveRecord::Migration
  def self.up
    add_column :test_plans, :status_override_reason, :string
  end

  def self.down
    remove_column :test_plans, :status_override_reason
  end
end
