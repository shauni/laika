class ChangeConditionsFreeTextNameToProblemName < ActiveRecord::Migration
  def self.up
    rename_column :conditions, :free_text_name, :problem_name
  end

  def self.down
    rename_column :conditions, :problem_name, :free_text_name
  end
end
