class SupportC32Importer 
  extend ImportHelper
  
  def self.template_id
   
  end
  
  def self.entry_xpath
   
  end
  
  def self.import_entry(entry_element)
    support = Support.new
    with_element(entry_element) do |element|
      
    end

    support
  end
end