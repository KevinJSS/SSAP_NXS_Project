# Preview all emails at http://localhost:3000/rails/mailers/minutes_mailer
class MinutesMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/minutes_mailer/send_minutes
  def send_minutes
    MinutesMailer.send_minutes
  end

end
