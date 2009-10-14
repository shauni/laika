class PatientFormBuilder < ActionView::Helpers::FormBuilder
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  include ApplicationHelper
  
  def select field, content, *args
    table_field field, super(field, content, *args)
  end

  def calendar_date_select field, *args
    table_field field, super(field, *args)
  end

  def collection_select field, *args
    table_field field, super(field, *args)
  end

  def text_field field, *args
    table_field(field, super(field, *args))
  end

  def check_box field, *args
    table_field(field, super(field, *args))
  end

  def submit label, *args
    table_controls(super(label, *args))
  end

  # Render nested form fields for person_name.
  def person_name_fields
    "".tap do |result|
      fields_for(:person_name) do |f|
        result << f.text_field(:name_prefix)
        result << f.text_field(:first_name)
        result << f.text_field(:last_name)
        result << f.text_field(:name_suffix)
      end
    end
  end
  
  # Render nested form fields for telecom.
  def telecom_fields
    "".tap do |result|
      fields_for(:telecom) do |f|
        result << f.text_field(:home_phone)
        result << f.text_field(:work_phone)
        result << f.text_field(:mobile_phone)
        result << f.text_field(:vacation_home_phone)
        result << f.text_field(:email)
        result << f.text_field(:url)
      end
    end
  end
  
  # Render nested form fields for address.
  def address_fields
    "".tap do |result|
      fields_for(:address) do |f|
        result << f.text_field(:street_address_line_one)
        result << f.text_field(:street_address_line_two)
        result << f.text_field(:city)
        result << f.select(:state, IsoState.select_options,
                           :include_blank => true)
        result << f.text_field(:postal_code)
        result << f.select(:iso_country_id, IsoCountry.select_options,
                           :include_blank => true)
      end
    end
  end

  def table_field field, content
    table_row(
      content_tag(:td,
        field.to_s.humanize + ' ' + requirements_for(object, field),
        :class => 'lighttext') +
      content_tag(:td, content))
  end

  def table_controls content
    table_row(content_tag(:td, '') + content_tag(:td, content))
  end

  def table_row content
    content_tag(:tr, content, :class => cycle('lightzebra', 'darkzebra'))
  end

end

