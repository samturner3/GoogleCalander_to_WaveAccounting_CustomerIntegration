# Preview all emails at http://localhost:3000/rails/mailers/model_mailer
class ModelMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/model_mailer/send_testimonial_request
  def send_testimonial_request
    ModelMailer.send_testimonial_request
  end

end
