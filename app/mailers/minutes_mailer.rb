class MinutesMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.minutes_mailer.send_minutes.subject
  #
  def send_minutes(user, user_email, minute, pdf)
    @user = user
    @minute = minute
    attachment_name = "MINUTA_#{(Project.find_by(id: @minute.project.id).name).gsub(' ', '-')}_#{@minute.meeting_date.strftime("%d-%m-%Y")}.pdf"
    attachments[attachment_name] = File.read(pdf)
    sleep(0.5)
    mail to: user_email, subject: "Minuta de reunión"
  end
end
