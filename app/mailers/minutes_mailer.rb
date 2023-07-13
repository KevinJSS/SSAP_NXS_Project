class MinutesMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.minutes_mailer.send_minutes.subject
  #
  def send_minutes(user, minute, pdf)
    @user = user
    @minute = minute
    attachments["minuta.pdf"] = File.read(pdf) #cambiar nombre

    mail to: @user.email, subject: "Minuta de reunión"
  end
end
