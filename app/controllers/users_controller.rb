class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[ show edit update ]
  before_action :get_change_log, only: %i[ show edit update ]

  def index
    @users = User.where(role: "admin").paginate(page: params[:page], per_page: 3)
  end

  def collaborator_index
    @collaborator_users = User.where(role: "collaborator").paginate(page: params[:page], per_page: 3)
  end

  def show
    redirect_to edit_user_registration_path if @user == current_user
    redirect_to edit_user_path(@user)
  end

  def edit
    redirect_to edit_user_registration_path if @user == current_user
    @user.build_emergency_contact if @user.emergency_contact.nil?
  end

  def update
    @user.valid?

    respond_to do |format|
      if !@user.errors.any? && @user.update(user_params)
        # Register the change log
        register_change_log

        #validate_emergency_contact_data

        format.html { redirect_to @user, notice: "#{user_role} actualizado correctamente" }
        format.json { render :show, status: :ok, location: @user }
      else
        @user.build_emergency_contact if @user.emergency_contact.nil?
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:fullname, :id_card, :phone, :email, :job_position, :address, :role, :account_number, :id_card_type, :marital_status, :education, :province, :canton, :district, :nationality, :gender, :birth_date, emergency_contact: [:fullname, :phone])
  end

  def user_role
    @user.role == "admin" ? "Administrador" : "Colaborador"
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

      @description << "(#{count}) Cambió #{attribute_name} de '#{old_value}' a '#{new_value}'. "
      attribute_name = ""
      count += 1
    end

    validate_emergency_contact_data(count)

    return if @description.empty?

    @description = "[#{Time.now.strftime("%d/%m/%Y - %H:%M")}] #{current_user.get_short_name} realizó los siguientes cambios: #{@description}"
    ChangeLog.new(table_id: @user.id, user_id: current_user.id, description: @description, table_name: "user").save
  end

  def validate_emergency_contact_data(count = 1)
    fullname = params[:user][:emergency_contact_attributes][:fullname]
    phone = params[:user][:emergency_contact_attributes][:phone]

    if @user.emergency_contact.nil?
      @em_contact = EmergencyContact.new(fullname: fullname, phone: phone, user: @user)
      @description += "(#{count}) Agregó información de contacto de emergencia. "
    else
      @user.emergency_contact.update(fullname: fullname, phone: phone)
      @em_contact = @user.emergency_contact
      changes = @em_contact.previous_changes
      
      attribute_name = ""
      changes.each do |attribute, values|
        old_value, new_value = values
        case attribute
        when "fullname"
          attribute_name = "el nombre completo"
        when "phone"
          attribute_name = "el número de teléfono del contacto de emergencia"
        end

        next if attribute_name.empty?

        @description << "(#{count}) Cambió #{attribute_name} de '#{old_value}' a '#{new_value}'. "
        attribute_name = ""
        count += 1
      end
    end

    if fullname.blank? && phone.blank?
      return

    elsif !@em_contact.valid?
      flash[:alert] = "Información opcional del contacto de emergencia no fue proporcionada correctamente."
      return
    end

    @em_contact.save
  end
end
