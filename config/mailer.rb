Rails.application.configure do

  config.action_mailer.default_options = { from: "SY Developers <#{ENV['SMTP_EMAIL']}>" }
  config.action_mailer.raise_delivery_errors = true
end
