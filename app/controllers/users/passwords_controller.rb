# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  def create
    user = User.find_by(email: params[:user][:email])

    if (user && user.role != "admin") || (user && user.role == "admin" && user.status == false)
      flash[:alert] = "Permiso denegado, contacta a un encargado del sistema."
      redirect_to new_user_session_path
      return
    elsif user && user.role == "admin" && user.status == true
      user.update(new_admin: false)
    end

    super
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  # def update
  #   super
  # end

  # protected

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end
end
