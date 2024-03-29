class UsersController < ApplicationController
  # The `before_action` callback method ensures that the user is authenticated
  # before accessing any action in this controller. It helps enforce the requirement
  # for a user to be logged in before interacting with the `UsersController`.
  before_action :authenticate_user!

  # The `before_action` callback method 'set_user' is called before the `show`, `edit` and `update` actions.
  # It helps to find the user by id and set it to the `@user` instance variable.
  before_action :set_user, only: %i[ show edit update ]

  # The `before_action` callback method 'get_change_log' is called before the `show`, `edit` and `update` actions.
  # It helps to find the change log of the user by id and set it to the `@user_change_log` instance variable.
  before_action :get_change_log, only: %i[ show edit update ]

  # This class variables are used to store the status and role changes of the user.
  @@status_changed = false
  @@new_status = ""
  @@role_changed = false
  @@new_role = ""

  # The `index` action is used to list all the users in the system.
  # It retrieves all the users from the database and stores them in the `@users` instance variable.
  # It also uses the `ransack` gem to implement the search functionality.
  # The `@admin_q` variable is used to store the search parameters.
  # The `@users` variable is used to store the search results.
  # The `@users` variable is paginated using the `will_paginate` gem.
  # The `@users` variable is sorted in ascending order by the `fullname` attribute.
  def index
    @admin_q = User.where(role: "admin").ransack(params[:q])
    @users = @admin_q.result(distinct: true).order(fullname: :asc).paginate(page: params[:page], per_page: 5)
  end

  # The `collaborator_index` action is used to list all the collaborators in the system.
  # It retrieves all the collaborators from the database and stores them in the `@collaborator_users` instance variable.
  # It also uses the `ransack` gem to implement the search functionality.
  # The `@collaborator_q` variable is used to store the search parameters.
  # The `@collaborator_users` variable is used to store the search results.
  # The `@collaborator_users` variable is paginated using the `will_paginate` gem.
  # The `@collaborator_users` variable is sorted in ascending order by the `fullname` attribute.
  def collaborator_index
    @collaborator_q = User.where(role: "collaborator").ransack(params[:q])
    @collaborator_users = @collaborator_q.result(distinct: true).order(fullname: :asc).paginate(page: params[:page], per_page: 5)
  end

  # The `show` action is used to display the details of a user.
  # It retrieves the user from the database and stores it in the `@user` instance variable.
  # If the user is equal to the current user, it redirects to the `edit_user_registration_path`.
  # Else it redirects to the `edit_user_path`.
  def show
    redirect_to edit_user_registration_path if @user == current_user
    redirect_to edit_user_path(@user)
  end

  # The `edit` action is used to display the edit form of a user.
  # It retrieves the user from the database and stores it in the `@user` instance variable.
  # If the user is equal to the current user, it redirects to the `edit_user_registration_path`.
  # Else it redirects to the `edit_user_path`.
  def edit
    redirect_to edit_user_registration_path if @user == current_user
    @user.build_emergency_contact if @user.emergency_contact.nil?
  end

  # The `update` action is used to update the details of a user.
  #
  # Break down of the `update` action:
  # 1. It retrieves the user from the database and stores it in the `@user` instance variable.
  # 2. It validates the user parameters.
  # 3. If the user is a collaborator and has projects assigned, it adds an error to the `@user` instance variable.
  # 4. If the user parameters are valid and the user is updated successfully, it redirects to the `edit` action.
  # 5. Else it adds an error to the `@user` instance variable and renders the `edit` action.
  # 6. Then it registers the change log.
  # 7. And finally in case the user role or status changed, it sends an email to the user.
  def update
    @user.valid?

    validate_id_card

    if params[:user][:role] == "collaborator" && @user.projects.any?
      @user.errors.add(:role, "no se puede cambiar debido a que tiene proyectos a su cargo.")
    end

    respond_to do |format|
      if !@user.errors.any? && @user.update(user_params)
        # Register the change log
        register_change_log

        # Send email announcing the change of role or status
        if @@status_changed && @user.role == "admin" && @user.new_admin && @@new_status == "Activo(a)"
          @user.send_reset_password_instructions if @user.status == true
          @user.update(new_admin: false)
        end

        if @@role_changed && @@new_role == "admin"
          @user.update(new_admin: true)
          
          if @user.status == true
            @user.send_reset_password_instructions if @user.role == "admin"
            @user.update(new_admin: false)
          end
        end

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

  def validate_id_card
    return if params[:user][:id_card].blank?
    id_card = params[:user][:id_card].strip.upcase

    return if id_card == "NO TIENE"

    if User.where(id_card: id_card).where.not(id: @user.id).exists?
      @user.errors.add(:id_card, "ya se encuentra en uso")
    end
  end

  # The `set_user` method is used to find the user by id and set it to the `@user` instance variable.
  # If the user is not found, it redirects to the `users_path` with an alert message.
  def set_user
    @user = User.find(params[:id]) rescue nil

    if @user.nil?
      redirect_to users_path, alert: "El usuario al que intenta acceder no existe."
    end
  end

  # The `user_params` method is used to whitelist the user parameters.
  # It only allows the permitted parameters to be submitted to the database.
  def user_params
    params.require(:user).permit(:fullname, :id_card, :phone, :email, :job_position, :address, :role, :status, :account_number, :id_card_type, :marital_status, :education, :province, :canton, :district, :nationality, :gender, :birth_date, emergency_contact: [:fullname, :phone])
  end

  # The `user_role` method is used to get the humanize role of the user.
  # It returns the humanize role of the user.
  def user_role
    @user.role == "admin" ? "Administrador" : "Colaborador"
  end

  # The `get_change_log` method is used to find the change log of the user by id and set it to the `@user_change_log` instance variable.
  # If the change log is empty, it sets the `@user_change_log` instance variable to `nil`.
  def get_change_log
    @user_change_log = ChangeLog.where(table_name: 'user', table_id: @user.id).order(created_at: :desc)
    if @user_change_log.empty? || @user_change_log.nil?
      @user_change_log = nil
    end
  end

  # The `register_change_log` method is used to register the change log of the user.
  # It retrieves the changes of the user and stores them in the `changes` variable.
  # It iterates over the `changes` variable and stores the changes in the `@description` variable.
  # It validates the emergency contact data.
  # It returns if the `@description` variable is empty.
  # It stores the change log in the database.
  # It sets the `@description` variable to an empty string.
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
        @@role_changed = true if old_value != new_value
        @@new_role = new_value if @@role_changed
      when "status"
        attribute_name = "el estado"
        old_value = old_value == true ? "Activo(a)" : "Inactivo(a)"
        new_value = new_value == true ? "Activo(a)" : "Inactivo(a)"
        @@status_changed = true if old_value != new_value
        @@new_status = new_value if @@status_changed

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

  # The `validate_emergency_contact_data` method is used to validate the emergency contact data.
  # It retrieves the emergency contact data from the params and stores it in the `fullname` and `phone` variables.
  # If the user doesn't have an emergency contact, it creates a new emergency contact.
  # Else it updates the emergency contact.
  # It retrieves the changes of the emergency contact and stores them in the `changes` variable.
  # It iterates over the `changes` variable and stores the changes in the `@description` variable.
  # Finally it stores the emergency contact in the database.
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
