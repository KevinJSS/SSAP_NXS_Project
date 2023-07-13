# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]
  # before_action :configure_permitted_parameters, if: :devise_controller?
  skip_before_action :require_no_authentication, only: [:new, :create]
  before_action :set_user, only: [:edit, :update]
  before_action :authenticate_user!
  before_action :validate_role_param, only: [:new]
  before_action :get_change_log, only: [:show, :edit, :update]

  # GET /resource/sign_up
  def new
    if user_signed_in? && current_user.role == "admin"
      @user = User.new(role: @role_param)
      @user.build_emergency_contact

      #byebug
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
        validate_emergency_contact_data
        create_change_log

        # Send email with password
        #@user.send_reset_password_instructions

        format.html { redirect_to @user, notice: "#{user_role} registrado correctamente" }
        format.json { render :show, status: :created, location: @user }
      else
        @user.build_emergency_contact if @user.emergency_contact.nil?

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
    if params[:user][:role] == "collaborator" && @user.projects.any?
      @user.errors.add(:role, "no se puede cambiar el rol de acceso del administrador(a) porque tiene proyectos a su cargo.")
    end

    validate_password_params

    respond_to do |format|
      if !@user.errors.any? && @user.update(user_params)
        # Register the change log
        register_change_log

        #validate_emergency_contact_data

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
    params.require(:user).permit(:fullname, :id_card, :phone, :email, :job_position, :address, :role, :status, :password, :password_confirmation, :account_number, :id_card_type, :marital_status, :education, :province, :canton, :district, :nationality, :gender, :birth_date, emergency_contact: [:fullname, :phone])
  end

  def create_change_log
    description = "[#{Time.now.strftime("%d/%m/%Y - %H:%M")}] #{current_user.get_short_name} crea este usuario."
    ChangeLog.new(table_id: @user.id, user_id: current_user.id, description: description, table_name: "user").save
  end

  def get_change_log
    @user_change_log = ChangeLog.where(table_name: 'user', table_id: @user.id) 
    if @user_change_log.empty? || @user_change_log.nil?
      @user_change_log = nil
    end
  end

  def register_change_log
    changes = @user.previous_changes

    @description = ""
    attribute_name = ""
    count = 1

    changes.each do |attribute, values|
      old_value, new_value = values

      case attribute
      when "email"
        attribute_name = "el correo electrónico"
      when "id_card"
        attribute_name = "la cédula"
      when "fullname"
        attribute_name = "el nombre completo"
      when "phone"
        attribute_name = "el teléfono"
      when "address"
        attribute_name = "la dirección"
      when "role"
        attribute_name = "el rol"
      when "status"
        attribute_name = "el estado"
        old_value = old_value == true ? "Activo(a)" : "Inactivo(a)"
        new_value = new_value == true ? "Activo(a)" : "Inactivo(a)"
      when "job_position"
        attribute_name = "el puesto de trabajo"
      when "account_number"
        attribute_name = "el número de cuenta"
      when "id_card_type"
        attribute_name = "el tipo de cédula"
      when "marital_status"
        attribute_name = "el estado civil"
      when "birth_date"
        attribute_name = "la fecha de nacimiento"
      when "province"
        attribute_name = "la provincia"
      when "canton"
        attribute_name = "el cantón"
      when "district"
        attribute_name = "el distrito"
      when "education"
        attribute_name = "el nivel de educación"
      when "gender"
        attribute_name = "el género"
      end

      if attribute_name.empty? then next end

      @description = @description + "(#{count}) Cambió #{attribute_name} de '#{old_value}' a '#{new_value}'. "
      attribute_name = ""
      count += 1
    end

    validate_emergency_contact_data(count)

    return if @description.empty?

    @description = "[#{Time.now.strftime("%d/%m/%Y - %H:%M")}] Ha realizado los siguientes cambios: #{@description}"
    ChangeLog.new(table_id: @user.id, user_id: current_user.id, description: @description, table_name: "user").save
    @description = ""
  end

  def user_role
    @user.role == "admin" ? "Administrador" : "Colaborador"
  end

  def validate_role_param
    @role_param ||= params[:role]

    if @role_param.nil?
      flash[:alert] = "Se intento ingresar mediante una url inválida, intenta nuevamente."
      redirect_to users_path if user_signed_in?
    end
  end

  #Checks for new password update adn current password presence and validation to authorize changes.
  def validate_password_params
    new_password = params[:user][:password]
    password_confirmation = params[:user][:password_confirmation]
    current_password = params[:user][:current_password]

    if new_password.blank? && password_confirmation.blank? 
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
      return #no password update
    end

    if current_password.blank?
      @user.errors.add(:current_password, "no puede estar en blanco.")
      return
    end

    if !@user.valid_password?(current_password)
      @user.errors.add(:current_password, "no es correcta.")
      return
    end
  end

  def validate_emergency_contact_data(count = 1)
    fullname = params[:user][:emergency_contact_attributes][:fullname]
    phone = params[:user][:emergency_contact_attributes][:phone]

    if @user.emergency_contact.nil?
      @em_contact = EmergencyContact.new(fullname: fullname, phone: phone, user: @user)
      @description += "(#{count}) Agregó información de contacto de emergencia. " if @description && !fullname.empty? && !phone.empty?
    else
      @user.emergency_contact.update(fullname: fullname, phone: phone)
      @em_contact = @user.emergency_contact
      changes = @em_contact.previous_changes
      
      attribute_name = ""
      changes.each do |attribute, values|
        old_value, new_value = values
        case attribute
        when "fullname"
          attribute_name = "el nombre completo del contacto de emergencia"
        when "phone"
          attribute_name = "el número de teléfono del contacto de emergencia"
        end

        next if attribute_name.empty?

        @description = @description + "(#{count}) Cambió #{attribute_name} de '#{old_value}' a '#{new_value}'. " if @description
        attribute_name = ""
        count += 1
      end
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
