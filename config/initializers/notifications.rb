# Configure both ActionMailer::Base, and the exception_notification plugin

def configure_subsystem(klass, config)
  config.each do |k,v|
    klass.send("#{k}=", v)
  end
end

laika_config_path = "#{RAILS_ROOT}/config/laika.yml"
yaml = YAML.load_file(laika_config_path)

# set exception_notification plugin
exception_notifier_config = yaml['exception_notifier'] || {}
exception_recipients = [ exception_notifier_config['exception_recipients'] ].flatten.map { |e| e.to_s }
exception_notifier_config = exception_notifier_config.merge(:exception_recipients => exception_recipients)
configure_subsystem(ExceptionNotifier, exception_notifier_config)

# set ActionMailer
configure_subsystem(ActionMailer::Base, yaml['action_mailer'] || {})
