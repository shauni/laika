class MoveCoverageRoleTypes < ActiveRecord::Migration
  
  class InsuranceProvider < ActiveRecord::Base
    belongs_to :coverage_role_type
    has_one :insurance_provider_patient
  end
  
  class InsuranceProviderPatient < ActiveRecord::Base
    belongs_to :coverage_role_type
    belongs_to :insurance_provider
  end
  
  def self.up
    add_column :insurance_provider_patients, :coverage_role_type_id, :integer
    InsuranceProvider.all.each do |ip|
      if ip.coverage_role_type.present?
        ip.insurance_provider_patient.coverage_role_type = ip.coverage_role_type
        ip.insurance_provider_patient.save!
      end
    end
    remove_column :insurance_providers, :coverage_role_type_id
  end

  def self.down
    add_column :insurance_providers, :coverage_role_type_id, :integer
    InsuranceProviderPatient.all.each do |ipp|
      if ipp.coverage_role_type.present?
        ipp.insurance_provider.coverage_role_type = ipp.coverage_role_type
        ipp.insurance_provider.save!
      end
    end
    remove_column :insurance_provider_patients, :coverage_role_type_id
  end
end
