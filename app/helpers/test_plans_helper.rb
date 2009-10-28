require 'sort_order'
module TestPlansHelper
  include SortOrderHelper

  def plan_when_tested plan
      plan.pending? ? 'not yet tested' : "#{time_ago_in_words plan.updated_at} ago"
  end

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

  def xds_metadata_single_attribute(metadata, attribute)
    "<tr>
      <td><strong>#{attribute.to_s.humanize}</strong></td>
      <td>#{metadata.send(attribute)}</td>
      <td></td>
    </tr>"
  end
  
  def xds_metadata_coded_attribute(metadata, attribute)
    "<tr>
      <td><strong>#{attribute.to_s.humanize}</strong></td>
      <td><strong>Display name</strong></td>
      <td>#{metadata.send(attribute).display_name}</td>
    </tr>
    <tr>
      <td></td>
      <td><strong>Code</strong></td>
      <td>#{metadata.send(attribute).code}</td>
    </tr>
    <tr>
      <td></td>
      <td><strong>Coding Scheme</strong></td>
      <td>#{metadata.send(attribute).coding_scheme}</td>
    </tr>
    <tr>
      <td></td>
      <td><strong>Classification Scheme</strong></td>
      <td>#{metadata.send(attribute).classification_scheme}</td>
    </tr>"
  end
end
