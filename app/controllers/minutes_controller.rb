class MinutesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_minute, only: %i[ show edit update destroy ]
  before_action :set_attendees, :set_projects
  before_action :get_change_log, only: %i[ show edit update ]

  # GET /minutes or /minutes.json
  def index
    @minutes = Minute.paginate(page: params[:page], per_page: 3)
  end

  # GET /minutes/1 or /minutes/1.json
  def show
    redirect_to edit_minute_path(@minute)
  end

  # GET /minutes/new
  def new
    @minute = Minute.new
  end

  # GET /minutes/1/edit
  def edit
  end

  # POST /minutes or /minutes.json
  def create
    @minute = Minute.new(minute_params)

    validate_attendees

    respond_to do |format|
      if !@minute.errors.any? && @minute.save
        #Create change log
        create_change_log

        format.html { redirect_to minute_url(@minute), notice: "Minute was successfully created." }
        format.json { render :show, status: :created, location: @minute }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @minute.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /minutes/1 or /minutes/1.json
  def update
    validate_attendees

    respond_to do |format|
      if !@minute.errors.any? && @minute.update(minute_params)

        #register change log
        register_change_log

        format.html { redirect_to minute_url(@minute), notice: "Minute was successfully updated." }
        format.json { render :show, status: :ok, location: @minute }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @minute.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /minutes/1 or /minutes/1.json
  def destroy
    @minute.destroy

    respond_to do |format|
      format.html { redirect_to minutes_url, notice: "Minute was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_minute
      @minute = Minute.find(params[:id])
    end

    def set_projects 
      @projects = Project.all
    end

    def set_attendees
      @attendees = User.all
    end

    def get_change_log
      @minutes_change_log = ChangeLog.where(table_name: 'minute', table_id: @minute.id) 
      if @minutes_change_log.empty? || @minutes_change_log.nil?
        @minutes_change_log = nil
      end
    end

    def create_change_log
      description = "[#{Time.now.strftime("%d/%m/%Y - %H:%M")}] #{current_user.get_short_name} crea esta minuta."
      ChangeLog.new(table_id: @minute.id, user_id: current_user.id, description: description, table_name: "minute").save
    end

    def register_change_log
      changes = @minute.previous_changes

      @description = ""
      attribute_name = ""
      count = 1

      changes.each do |attribute, values|
        old_value, new_value = values

        case attribute
        when "meeting_title"
          attribute_name = "el título de la reunión"
        when "meeting_date"
          attribute_name = "la fecha de la reunión"
        when "start_time"
          attribute_name = "la hora de inicio de la reunión"
          old_value = old_value.strftime("%H:%M %p")
          new_value = new_value.strftime("%H:%M %p")
        when "end_time"
          attribute_name = "la hora de finalización de la reunión"
          old_value = old_value.strftime("%H:%M %p")
          new_value = new_value.strftime("%H:%M %p")
        when "meeting_objectives"
          attribute_name = "los objetivos de la reunión"
        when "discussed_topics"
          attribute_name = "los temas discutidos en la reunión"
        when "pending_topics"
          attribute_name = "los temas pendientes de la reunión"
        when "agreements"
          attribute_name = "los acuerdos de la reunión"
        when "meeting_notes"
          attribute_name = "las notas de la reunión"
        when "project_id"
          attribute_name = "el proyecto"
          old_value = Project.find(old_value).name
          new_value = Project.find(new_value).name
        end

        next if attribute_name.empty?

        @description = @description + "(#{count}) Cambió #{attribute_name} de '#{old_value}' a '#{new_value}'. "
        attribute_name = ""
        count += 1
      end

      validate_attendees_changes(count)

      return if @description.empty?

      @description = "[#{Time.now.strftime("%d/%m/%Y - %H:%M")}] #{current_user.get_short_name} realizó los siguientes cambios: #{@description}"
      ChangeLog.new(table_id: @minute.id, user_id: current_user.id, description: @description, table_name: "minute").save
      @description = ""
    end

    def validate_attendees
      #validate if nested attributes are empty
      if params[:minute][:minutes_users_attributes].nil? || params[:minute][:minutes_users_attributes].empty?
        @minute.errors.add(:minutes_users, "es necesario seleccionar al menos un asistente")
      end

      #validate if all nested attributes are marked to be destroyed
      destroyed_attemdees_validation

      #Duplicated attendees validation
      duplicate_attendees_validation
    end

    def destroyed_attemdees_validation
      #validate if all nested attributes are marked to be destroyed
      if !@minute.new_record?
        deletedAssociations = 0
        nested_attributes = params[:minute][:minutes_users_attributes]
        nested_attributes.each do |index, attributes|
          destroy_value = attributes["_destroy"]
          deletedAssociations += 1 if destroy_value != "false"
        end

        if @minute.minutes_users.count == deletedAssociations
          @minute.errors.add(:minutes_users, "es necesario seleccionar al menos un asistente")
          false
        end
      end
    end

    def duplicate_attendees_validation
      nested_attributes = params[:minute][:minutes_users_attributes]
      return unless !nested_attributes.nil?
      
      user_ids = []
      nested_attributes.each do |index, attributes|
        user_ids << attributes["user_id"] if attributes["_destroy"] == "false"
      end

      duplicates = user_ids.select { |id| user_ids.count(id) > 1 }.uniq
      if !duplicates.empty?
        @minute.errors.add(:minutes_users, "no puede haber asistentes duplicados")
      end
    end

    def validate_attendees_changes(count)
      return if @minute.errors.any?
      new_attributes = params.fetch(:minute, {}).fetch(:minutes_users_attributes, {}).values

      added_users = new_attributes.reject { |new_user| @minute.minutes_users.any? { |existing_user| existing_user.id.to_s == new_user[:id] || new_user[:_destroy] != "false" } }
      removed_users = new_attributes.reject { |user| user[:_destroy] == "false" }

      if !removed_users.empty?
        @description = @description + " (#{count}) Eliminó los/las siguientes asistentes: "

        removed_users.each do |user|
          @description = @description + "#{User.find(user[:user_id]).get_short_name}, "
        end

        @description = @description.chomp(", ")
        count += 1
      end

      if !added_users.empty?
        @description = @description + " (#{count}) Agregó los/las siguientes asistentes: "

        added_users.each do |user|
          @description = @description + "#{User.find(user[:user_id]).get_short_name}, "
        end

        @description = @description.chomp(", ")
        count += 1
      end
    end

    # Only allow a list of trusted parameters through.
    def minute_params
      params.require(:minute).permit(:meeting_title, :meeting_date, :start_time, :end_time, :meeting_objectives, :discussed_topics, :pending_topics, :agreements, :meeting_notes, :project_id, minutes_users_attributes: [:id, :user_id, :_destroy])
    end
end
