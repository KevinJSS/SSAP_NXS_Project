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
        format.html { redirect_to @user, notice: "#{user_role} registrado correctamente" }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /resource/edit
  def edit
    @user.build_emergency_contact if @user.emergency_contact.nil?
  end

  # PUT /resource
  def update
    validate_password_params

    respond_to do |format|
      if !@user.errors.any? && @user.update(user_params)

        validate_emergency_contact_data

        format.html { redirect_to edit_user_registration_path, notice: "Su perfil ha sido actualizado correctamente." }
        format.json { render :show, status: :ok, location: @user }
      else
        @user.build_emergency_contact if @user.emergency_contact.nil?

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
    params.require(:user).permit(:fullname, :id_card, :phone, :email, :job_position, :address, :role, :password, :password_confirmation, emergency_contact: [:fullname, :phone])
  end

  def user_role
    @user.role == "admin" ? "Administrador" : "Trabajador"
  end

  #Checks for new password update adn current password presence and validation to authorize changes.
  def validate_password_params
    new_password = params[:user][:password]
    password_confirmation = params[:user][:password_confirmation]
    current_password = params[:user][:current_password]

    if new_password.blank? && password_confirmation.blank? 
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    if current_password.blank?
      @user.errors.add(:current_password, :presence, message: "is blank")
    else
      @user.errors.add(:current_password, message: "is incorrect") if !@user.valid_password?(current_password)
    end
  end

  def validate_emergency_contact_data
    fullname = params[:user][:emergency_contact_attributes][:fullname]
    phone = params[:user][:emergency_contact_attributes][:phone]

    if @user.emergency_contact.nil?
      @em_contact = EmergencyContact.new(fullname: fullname, phone: phone, user: @user)
    else
      @user.emergency_contact.update(fullname: fullname, phone: phone)
      @em_contact = @user.emergency_contact
    end

    if fullname.blank? && phone.blank?
      return #emergency contact data not provided

    elsif !@em_contact.valid?
      flash[:alert] = "Información opcional del contacto de emergencia no fue proporcionada correctamente."
      return
    end

    @em_contact.save
  end

  def set_user
    @user = current_user
  end

   # def configure_permitted_parameters
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:fullname, :id_card, :phone, :email, :job_position, :address, :role])
  # end

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
