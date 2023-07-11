class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[ show edit update ]
  before_action :get_change_log, only: %i[ show edit update ]

  def index
    @admin_q = User.where(role: "admin").ransack(params[:q])
    @users = @admin_q.result(distinct: true).order(fullname: :asc).paginate(page: params[:page], per_page: 3)
  end

  def collaborator_index
    @collaborator_q = User.where(role: "collaborator").ransack(params[:q])
    @collaborator_users = @collaborator_q.result(distinct: true).order(fullname: :asc).paginate(page: params[:page], per_page: 3)
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

    if params[:user][:role] == "collaborator" && @user.projects.any?
      @user.errors.add(:role, "no se puede cambiar debido a que tiene proyectos a su cargo.")
    end

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
    @user = User.find(params[:id]) rescue nil

    if @user.nil?
      redirect_to users_path, alert: "El usuario al que intenta acceder no existe."
    end
  end

  def user_params
    params.require(:user).permit(:fullname, :id_card, :phone, :email, :job_position, :address, :role, :status, :account_number, :id_card_type, :marital_status, :education, :province, :canton, :district, :nationality, :gender, :birth_date, emergency_contact: [:fullname, :phone])
  end

  def user_role
    @user.role == "admin" ? "Administrador" : "Colaborador"
  end

  def get_change_log
    @user_change_log = ChangeLog.where(table_name: 'user', table_id: @user.id).order(created_at: :desc)
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
      old_value = old_value.strip if old_value.is_a?(String) || old_value.is_a?(Text)
      new_value = new_value.strip if new_value.is_a?(String) || new_value.is_a?(Text)

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
        old_value = @user.get_humanize_id_card_type(old_value)
        new_value = @user.get_humanize_id_card_type(new_value)
      when "marital_status"
        attribute_name = "el estado civil"
        old_value = @user.get_humanize_marital_status(old_value)
        new_value = @user.get_humanize_marital_status(new_value)
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
        old_value = @user.get_humanize_education(old_value)
        new_value = @user.get_humanize_education(new_value)
      when "gender"
        attribute_name = "el género"
        old_value = @user.get_humanize_gender(old_value)
        new_value = @user.get_humanize_gender(new_value)
      end

      if attribute_name.empty? then next end

      @description = @description + "(#{count}) Cambió #{attribute_name} de '#{old_value}' a '#{new_value}'. "
      attribute_name = ""
      count += 1
    end

    validate_emergency_contact_data(count)

    return if @description.empty?

    @description = "[#{Time.now.strftime("%d/%m/%Y - %H:%M")}] #{current_user.get_short_name} realizó los siguientes cambios: #{@description}"
    ChangeLog.new(table_id: @user.id, user_id: current_user.id, description: @description, table_name: "user").save
    @description = ""
  end

  def validate_emergency_contact_data(count = 1)
    fullname = params[:user][:emergency_contact_attributes][:fullname]
    phone = params[:user][:emergency_contact_attributes][:phone]

    if @user.emergency_contact.nil?
      @em_contact = EmergencyContact.new(fullname: fullname, phone: phone, user: @user)
      @description += "(#{count}) Agregó información de contacto de emergencia. " if @description && !fullname && !phone
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
      return

    elsif !@em_contact.valid?
      flash[:alert] = "Información opcional del contacto de emergencia no fue proporcionada correctamente."
      return
    end

    @em_contact.save
  end
end
