# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]
  # before_action :configure_permitted_parameters, if: :devise_controller?
  skip_before_action :require_no_authentication, only: [:new, :create]
  before_action :set_user, only: [:edit, :update]
  before_action :authenticate_user!

  # GET /resource/sign_up
  def new
    if user_signed_in? && current_user.role == "admin"
      super
    else
      redirect_to root_path
    end
  end

  # POST /resource
  def create
    @user = User.new(user_params)
    @user.password = "Usuario_#{@user.id_card}" #Se debe generar un contrasena aleatoria y enviarla por el correo registrado

    respond_to do |format|
      if @user.save
        format.html { redirect_to users_path_url, notice: "#{@user.role == "admin" ? "Administrador" : "Trabajador"} registrado correctamente" }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  def update
    @user = current_user

    current_password = params[:user][:current_password]
    if current_password.blank?
      @user.errors.add(:current_password, :presence, message: "is blank")
    else
      @user.errors.add(:current_password, message: "is incorrect") if !@user.valid_password?(current_password)
    end

    respond_to do |format|
      if !@user.errors.any? && @user.update(user_params)
        format.html { redirect_to users_path_url(@user), notice: "#{@user.role == "admin" ? "Administrador" : "Trabajador"} actualizado correctamente" }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  protected

  def user_params
    params.require(:user).permit(:fullname, :id_card, :phone, :email, :job_position, :address, :role)
  end

  # def configure_permitted_parameters
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:fullname, :id_card, :phone, :email, :job_position, :address, :role])
  # end

  def set_user
    if params[:user_id].present?
      @user = User.find(params[:user_id])
    else
      @user = current_user
    end
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
