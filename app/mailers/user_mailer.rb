class UserMailer < Devise::Mailer
    include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
    default template_path: 'user_mailer/mailer' # to make sure that your mailer uses the devise views
  
    def confirmation_instructions(record, token, opts = {})
      opts[:subject] = "Confirmar cuenta"
      super
    end
  
    def reset_password_instructions(record, token, opts = {})
      opts[:subject] = "Restablecer contraseña"
      super
    end
  end
