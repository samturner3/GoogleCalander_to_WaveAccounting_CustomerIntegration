class ModelMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.model_mailer.send_testimonial_request.subject
  #
  def send_testimonial_request(booking, client)
    @booking = booking
    @client = client
    mail  to: "accounts@cardclonesydney.com.au", subject: "Testimonial Request Sent"
  end
end
