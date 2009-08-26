class AddUmlsStatusToTestPlan < ActiveRecord::Migration
  def self.up
    add_column :test_plans, :umls_enabled, :boolean
  end

  def self.down
    remove_column :test_plans, :umls_enabled
  end
end
