require "test_helper"

class MinutesMailerTest < ActionMailer::TestCase
  test "send_minutes" do
    mail = MinutesMailer.send_minutes
    assert_equal "Send minutes", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
