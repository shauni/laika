class AdvanceDirectiveC32Importer 
  extend ImportHelper
  
  def self.template_id
    '2.16.840.1.113883.10.20.1.1'
  end
  
  def self.entry_xpath
    ""
  end
  
  def self.import_entry(entry_element)
    directive = AdvanceDirective.new
    with_element(entry_element) do |element|
      
    end

    directive
  end
end