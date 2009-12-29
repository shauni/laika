class AddCodeSystemIdToAllergies < ActiveRecord::Migration
 
  class Allergy < ActiveRecord::Base
    belongs_to :code_system
  end

  class CodeSystem < ActiveRecord::Base; end

  def self.up
    add_column :allergies, :code_system_id, :integer
    # Set all allergies without a code system to RxNorm
    code_system = CodeSystem.find_by_code('2.16.840.1.113883.6.88')
    Allergy.find_all_by_code_system_id(nil).each do |a|
      a.code_system = code_system
      a.save!
    end
  end

  def self.down
    remove_column :allergies, :code_system_id
  end
end
