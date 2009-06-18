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
    affinity_domain_identifier.andand.patient_identifier
  end

  def affinity_domain
    affinity_domain_identifier.andand.affinity_domain
  end

  def to_c32(xml = Builder::XmlMarkup.new)

    xml.id("extension" => person_identifier)

    address.andand.to_c32(xml)
    telecom.andand.to_c32(xml)

    xml.patient do
      person_name.andand.to_c32(xml)
      gender.andand.to_c32(xml)
      if date_of_birth
        xml.birthTime("value" => date_of_birth.strftime("%Y%m%d"))  
      end

      marital_status.andand.to_c32(xml)
      religion.andand.to_c32(xml)
      race.andand.to_c32(xml)
      ethnicity.andand.to_c32(xml)

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
    self.gender = Gender.find(:all).sort_by{rand}.first
    self.race = Race.find(:all).sort_by{rand}.first
    self.ethnicity = Ethnicity.find(:all).sort_by{rand}.first
    self.religion = Religion.find(:all).sort_by{rand}.first
    self.marital_status = MaritalStatus.find(:all).sort_by{rand}.first
    self.date_of_birth = DateTime.new(1930 + rand(78), rand(12) + 1, rand(28) + 1)

    self.address = Address.new
    self.address.randomize()

    self.telecom = Telecom.new
    self.telecom.randomize()

  end

end
