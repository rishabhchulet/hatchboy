Hatchboy::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.action_mailer.default_url_options = { :host => 'hatchboy.shakuro.com' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address:              'smtp.gmail.com',
    port:                 587,
    user_name:            'test@shakuro.com',
    password:             'Rediska5',
    authentication:       'plain',
    enable_starttls_auto: true
  }

end
