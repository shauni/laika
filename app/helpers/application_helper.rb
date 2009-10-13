# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # Return true if +name+ contains the name of the current controller, false otherwise.
  def current_controller?(name)
    controller.controller_name == name.to_s
  end

  # Form helper for building forms using PatientFormBuilder.
  def patient_form_for(record, *args, &proc)
    options = args.extract_options!
    update = { :success => options[:update], :failure => nil }
    remote_form_for(record, *(args << options.merge(:builder => PatientFormBuilder, :update => update)), &proc)
  end

  # Return an HTML span describing the requirements for the given model field.
  def requirements_for(model, field)
    return '' unless model.respond_to?(:requirements) && model.requirements
    case model.requirements[field]
      when :required
        content_tag :span, 'Required',
          :class => 'validation_for required'
      when :nhin_required
        content_tag :span, 'Required (NHIN)',
          :class => 'validation_for required'
      when :hitsp_required
        content_tag :span, 'Required (HITSP R)',
          :class => 'validation_for required'
      when :hitsp_r2_required
        content_tag :span, 'Required (HITSP R2)',
          :class => 'validation_for required'
      when :hitsp_optional
        content_tag :span, 'Optional (HITSP R)',
          :class => 'validation_for'
      when :hitsp_r2_optional
        content_tag :span, 'Optional (HITSP R2)',
          :class => 'validation_for'
      else
        ''
    end
  end

  # If the file "#{Rails.root}/public/javascripts/#{name}.js" exists, return a javascript
  # include tag that loads this file in the client.
  def javascript_include_if_exists(name, *args)
    if FileTest.exist?(File.join(Rails.root, 'public', 'javascripts', "#{name}.js"))
      javascript_include_tag(name, *args)
    end
  end

end
