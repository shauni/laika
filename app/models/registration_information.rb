class RegistrationInformation < ActiveRecord::Base

  strip_attributes!

  belongs_to :race
  belongs_to :ethnicity
  belongs_to :marital_status
  belongs_to :gender
  belongs_to :religion
  belongs_to :affinity_domain_identifier,
    :foreign_key => 'affinity_domain_id', :class_name => 'PatientIdentifier'

  include PatientChild
  include PersonLike

  def requirements
    {
      :document_timestamp => :required,
      :affinity_domain_id => :required,
      :gender_id => :required,
      :date_of_birth => :required,
      :marital_status_id => :hitsp_r2_optional,
    }
  end

  def person_identifier
    affinity_domain_identifier.try(:patient_identifier)
  end

  def affinity_domain
    affinity_domain_identifier.try(:affinity_domain)
  end

  def to_c32(xml = Builder::XmlMarkup.new)

    xml.id("extension" => person_identifier)

    address.try(:to_c32, xml)
    telecom.try(:to_c32, xml)

    xml.patient do
      person_name.try(:to_c32, xml)
      gender.try(:to_c32, xml)
      if date_of_birth
        xml.birthTime("value" => date_of_birth.to_s(:brief))  
      end

      marital_status.try(:to_c32, xml)
      religion.try(:to_c32, xml)
      race.try(:to_c32, xml)
      ethnicity.try(:to_c32, xml)

      # do the gaurdian stuff here non gaurdian is placed elsewhere
      if patient.support &&
         patient.support.contact_type &&
         patient.support.contact_type.code == "GUARD"
        patient.support.to_c32(xml)
      end  

      patient.languages.to_c32(xml)

    end

  end

  def clone
    copy = super
    %w[ race ethnicity marital_status gender religion ].each do |attr|
      copy.send("#{attr}=", send(attr))
    end
    copy
  end

  def randomize(patient)
    pi = patient.patient_identifiers.build
    pi.randomize
    self.affinity_domain_identifier = pi

    self.document_timestamp = DateTime.new(2000 + rand(8), rand(12) + 1, rand(28) + 1)

    name = PersonName.new
    name.first_name = Faker::Name.first_name
    name.last_name = Faker::Name.last_name
    self.person_name = name
    self.race = Race.find :random
    self.ethnicity = Ethnicity.find :random
    self.religion = Religion.find :random
    self.marital_status = MaritalStatus.find :random
    
    # smarter fake data from US 2000 census
    self.gender = Gender.find_by_name(rand(100) + 1 > 51 ? "Male" : "Female")
    
    # 20% 0-14, 67% 15-65, 13% 65-100
    age_percent = rand(100) + 1
    if age_percent <= 20
      age_bracket = 0
      age_range = 15
    elsif age_percent <= 87
      age_bracket = 15
      age_range = 40
    else age_percent <= 100
      age_bracket = 65
      age_range = 35
    end
    self.date_of_birth = DateTime.new(Date.today.year - age_bracket - rand(age_range), rand(12) + 1, rand(28) + 1)

    self.address = Address.new
    self.address.randomize()

    self.telecom = Telecom.new
    self.telecom.randomize()

  end

end
