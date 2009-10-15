class SocialHistory < ActiveRecord::Base

  strip_attributes!

  belongs_to :social_history_type

  include PatientChild
  include Commentable

  def to_c32(xml)
    xml.entry do
      xml.observation("classCode" => "OBS", "moodCode" => "EVN") do
        xml.templateId("root" => "2.16.840.1.113883.10.20.1.33", "assigningAuthorityName" => "CCD")

        xml.id
        if social_history_type
              xml.code("code" => social_history_type.code, 
                       "displayName" => social_history_type.name, 
                       "codeSystem" => "2.16.840.1.113883.6.96",
                       "codeSystemName" => "SNOMED CT") do
                xml.originalText do
                  xml.reference("value" => "social-history-" + id.to_s)
                end
              end
            end 
        xml.statusCode("code" => "completed")
        if start_effective_time != nil || start_effective_time != nil
              xml.effectiveTime do
                if start_effective_time != nil 
                  xml.low("value" => start_effective_time.to_s(:brief))
                end
                if end_effective_time != nil
                  xml.high("value" => end_effective_time.to_s(:brief))
                else
                  xml.high("nullFlavor" => "UNK")
                end
              end
            end
        #value
      end
    end
  end
  
   def randomize(birth_date)
    self.start_effective_time = DateTime.new(birth_date.year + rand(DateTime.now.year - birth_date.year), rand(12) + 1, rand(28) +1)
    self.social_history_type = SocialHistoryType.find :random
  end

  def self.c32_component(social_history, xml)
    if social_history.size > 0
      xml.component do
        xml.section do
          xml.templateId("root" => "2.16.840.1.113883.10.20.1.15", 
                         "assigningAuthorityName" => "CCD")
          xml.code("code" => "29762-2", 
                   "codeSystem" => "2.16.840.1.113883.6.1",
                   "codeSystemName" => "LOINC")
          xml.title "Social History"
          # XML content inspection
          yield
        end
      end
    end
  end

end
