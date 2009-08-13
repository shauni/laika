require 'sort_order'
module TestPlansHelper
  include SortOrderHelper

  def action_list_items test_plan, opts
    test_plan.test_actions.map do |k, v|
      if k =~ />$/
        content_tag 'li',
          link_to_remote(k[0..-2], :url => {
            :controller => 'test_plans', :action => v, :id => test_plan
          }, :update => opts[:update])
      else
        content_tag 'li',
          link_to(k, :controller => 'test_plans', :action => v, :id => test_plan)
      end
    end
  end

  # method used to mark the elements in the document that have errors so they 
  # can be linked to
  def match_errors(errors, doc)
    error_map = {}
    error_id = 0
    @error_attributes = []
    locs = errors.collect{|e| e.location}
    locs.compact!

    locs.each do |location|
      node = REXML::XPath.first(doc ,location)
      if(node)
        elem = node
        if node.class == REXML::Attribute
          @error_attributes << node
          elem = node.element
        end
        if elem
          unless elem.attributes['error_id']
            elem.add_attribute('error_id',"#{error_id}") 
            error_id += 1
          end
          error_map[location] = elem.attributes['error_id']
        end
      end
    end

    error_map
  end
end
