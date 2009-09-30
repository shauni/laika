class Condition < ActiveRecord::Base

  strip_attributes!

  belongs_to :problem_type

  include PatientChild
  include Commentable

  def requirements
    {
      :start_event => :hitsp_r2_optional,
      :end_event => :hitsp_r2_optional,
      :problem_type_id => :hitsp_r2_required,
      :snowmed_problem => :required,
    }
  end


 
  def to_c32(xml)
    xml.entry do
      xml.act("classCode" => "ACT", "moodCode" => "EVN") do
        xml.templateId("root" => "2.16.840.1.113883.10.20.1.27", "assigningAuthorityName" => "CCD")
        xml.templateId("root" => "2.16.840.1.113883.3.88.11.32.7", "assigningAuthorityName" => "HITSP/C32")
        xml.templateId("root" => "2.16.840.1.113883.3.88.11.83.7", "assigningAuthorityName" => "HITSP C83")
        xml.templateId("root" => "1.3.6.1.4.1.19376.1.5.3.1.4.5.1")
        xml.templateId("root" => "1.3.6.1.4.1.19376.1.5.3.1.4.5.2")
        xml.statusCode("code" => "completed")		
     		
     		 if start_event != nil || end_event != nil
          xml.effectiveTime do
            if start_event != nil 
              xml.low("value" => start_event.to_s(:brief))
            end
            if end_event != nil
              xml.high("value" => end_event.to_s(:brief))
            else
              xml.high("nullFlavor" => "UNK")
            end
          end
        end

        xml.id
        xml.code("nullFlavor"=>"NA")
        xml.entryRelationship("typeCode" => "SUBJ", "inversionInd" => "false") do
          xml.observation("classCode" => "OBS", "moodCode" => "EVN") do
            xml.templateId("root" => "2.16.840.1.113883.10.20.1.28", "assigningAuthorityName" => "CCD")
            xml.templateId("root" => "1.3.6.1.4.1.19376.1.5.3.1.4.5", "assigningAuthorityName" => "IHE PCC" )
            xml.id
            
            if problem_type
              xml.code("code" => problem_type.code, 
                       "displayName" => problem_type.name, 
                       "codeSystem" => "2.16.840.1.113883.6.96", 
                       "codeSystemName" => "SNOMED CT")
            end 
            xml.text do
              xml.reference("value" => "#problem-"+id.to_s)
            end
            xml.statusCode("code" => "completed")
            if start_event.present? || end_event.present?
              xml.effectiveTime do
                if start_event.present?
                  xml.low("value" => start_event.to_s(:brief))
                end
                if end_event.present?
                  xml.high("value" => end_event.to_s(:brief))
                else
                  xml.high("nullFlavor" => "UNK")
                end
              end
            end
            # only write out the coded value if the name of the condition is in the SNOMED list
            if free_text_name
              snowmed_problem = SnowmedProblem.find(:first, :conditions => {:name => free_text_name})
              if snowmed_problem
                xml.value("xsi:type" => "CD", 
                        "code" => snowmed_problem.code, 
                        "displayName" => free_text_name,
                        "codeSystem" => "2.16.840.1.113883.6.96",
                        "codeSystemName" => 'SNOMED CT')
              end
            end
          end
        end
      end
    end
  end

  def randomize(birth_date)
    self.start_event = DateTime.new(birth_date.year + rand(DateTime.now.year - birth_date.year), rand(12) + 1, rand(28) +1)
    self.problem_type = ProblemType.find(:random)
    self.free_text_name = SnowmedProblem.find(:random).try(:name)
  end



  def self.c32_component(conditions, xml)
    if conditions.size > 0
      xml.component do
        xml.section do
          xml.templateId("root" => "2.16.840.1.113883.10.20.1.11",
                         "assigningAuthorityName" => "CCD")
          xml.templateId("root" => "1.3.6.1.4.1.19376.1.5.3.1.3.6", #C32 2.4
                          "assigningAuthorityName" => "CCD")
          
          xml.code("code" => "11450-4",
                   "displayName" => "Problems",
                   "codeSystem" => "2.16.840.1.113883.6.1",
                   "codeSystemName" => "LOINC")
          xml.title "Conditions or Problems"
          xml.text do
            xml.table("border" => "1", "width" => "100%") do
              xml.thead do
                xml.tr do
                  xml.th "Problem Name"
                  xml.th "Problem Type"
                  xml.th "Problem Date"
                end
              end
              xml.tbody do
               conditions.try(:each) do |condition|
                  xml.tr do
                    if condition.free_text_name != nil
                      xml.td do
                        xml.content(condition.free_text_name, 
                                     "ID" => "problem-"+condition.id.to_s)
                      end
                    else
                      xml.td
                    end 
                    if condition.problem_type != nil
                      xml.td condition.problem_type.name
                    else
                      xml.td
                    end  
                    if condition.start_event != nil
                      xml.td condition.start_event.to_s(:brief)
                    else
                      xml.td
                    end
                  end
                end
              end
            end
          end

          # XML content inspection
          yield

        end
      end
    end
  end
end
