class AddCodeSystemIdToAllergies < ActiveRecord::Migration
  def self.up
    add_column :allergies, :code_system_id, :integer
  end

  def self.down
    remove_column :allergies, :code_system_id
  end
end
