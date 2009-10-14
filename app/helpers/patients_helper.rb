require_dependency 'sort_order'

module PatientsHelper
  include SortOrderHelper

  def view_row object, field
    content_tag(:tr,
                content_tag(:td, field.to_s.humanize, :class => 'lighttext') +
                content_tag(:td, html_escape(object.send(field))),
                :class => cycle('darkzebra', 'lightzebra'))
  end
end
