require 'test_helper'

class ModelMailerTest < ActionMailer::TestCase
  test "send_testimonial_request" do
    mail = ModelMailer.send_testimonial_request
    assert_equal "Send testimonial request", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
