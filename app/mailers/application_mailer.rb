class ApplicationMailer < ActionMailer::Base
  default template_path: 'mailer'
  default from: 'contact@sydevelopers.com'
  layout 'mailer'
end
