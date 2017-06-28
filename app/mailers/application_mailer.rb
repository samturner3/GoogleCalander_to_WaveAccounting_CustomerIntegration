class ApplicationMailer < ActionMailer::Base
  default from: 'accounts@cardclonesydney.com.au'
  default bcc: 'bcc-1541-11932@trustspot.net'
  layout 'mailer'
end
