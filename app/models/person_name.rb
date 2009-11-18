class PersonName < ActiveRecord::Base

  strip_attributes!

  belongs_to :nameable, :polymorphic => true

  after_save { |r| r.nameable.try(:patient).try(:update_attributes, :updated_at => DateTime.now) }

  def blank?
    %w[ name_prefix first_name last_name name_suffix ].all? {|a| read_attribute(a).blank? }
  end

  def requirements
    case nameable_type
    when 'RegistrationInformation'
    {
      :first_name => :required,
      :last_name => :required,
    }
    when 'InformationSource':
    {
      :first_name => :required,
      :last_name => :required,
    }
    when 'Provider':
    {
      :first_name => :hitsp_r2_optional,
      :last_name => :hitsp_r2_optional,
    }
    when 'InsuranceProviderPatient', 'InsuranceProviderSubscriber', 'InsuranceProviderGuarantor':
    {
      :first_name => :required,
      :last_name => :required,

    }
    when 'AdvanceDirective':
    {
      :first_name => :hitsp_required,
      :last_name => :hitsp_required

    }
    when 'Encounter':
    {
      :first_name => :hitsp_r2_required,
      :last_name => :hitsp_r2_required,
    }
    end
  end



  def to_c32(xml)
    xml.name do
      if name_prefix.present?
        xml.prefix(name_prefix)
      end
      if first_name.present?
        xml.given(first_name, "qualifier" => "CL")
      end
      if middle_name.present?
        xml.given(middle_name, "qualifier" => "BR")
      end
      if last_name.present?
        xml.family(last_name, "qualifier" => "BR")
      end
      if name_suffix.present?
        xml.suffix(name_suffix)
      end
    end
  end

end
