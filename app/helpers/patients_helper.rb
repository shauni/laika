require_dependency 'sort_order'

module PatientsHelper
  include SortOrderHelper

  def cycle_row
    cycle('darkzebra','lightzebra')
  end

  def view_row object, field
    content_tag(:tr,
                content_tag(:td, field.to_s.humanize, :class => 'lighttext') +
                content_tag(:td, html_escape(object.send(field))),
                :class => cycle_row)
  end
  
  def link_to_module title, element
    link_to_function title, "scroll_to_module_and_highlight('#{element}', 1.0)"
  end

  def link_to_add_module patient, identifier
    link_to_remote "Add #{identifier.to_s.titleize}",
       :method   => 'get',
       :url      => send("new_patient_#{identifier}_path", patient),
       :update   => { :success => "add#{identifier.to_s.camelize}" },
       :position => :before
  end

  def show_children_module ident, *args
    opts = args.extract_options!
    table_name = opts[:table_name] || ident
    title = args.first || ident.to_s.titleize
    render :partial => 'module_children', :locals => {
      :ident => ident.to_s, :title => title,
      :table_name => table_name.to_s
    }
  end

  def show_child_module ident
    render :partial => 'module_child', :locals => {
      :ident => ident.to_s,
      :item => @patient.send(ident)
    }
  end
end
