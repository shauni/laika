class TelecomC32Importer
  extend ImportHelper

  def self.import(telecom_container_element)
    tel = Telecom.new
    if telecom_container_element
      all_telecoms =  REXML::XPath.match(telecom_container_element, "cda:telecom", ImportHelper::DEFAULT_NAMESPACES)
      all_telecoms.each { |e|
        val = e.attributes['value']
        if val
          type = e.attributes['use']
          if !type && val.include?("mailto")
            type = "email"
          end  

          case type 
          when "HP":    tel.home_phone = val.gsub('tel:', '')
          when "WP":    tel.work_phone = val.gsub('tel:', '')
          when "MC":    tel.mobile_phone = val.gsub('tel:', '')
          when "email": tel.email = val.gsub('mailto:', '')
          else          tel.url = val
          end 
        end
      }
    end
    tel
  end

end