class ActivitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_activity, only: %i[ show edit update destroy ]
  before_action :set_collaborators, :set_projects, :set_phases
  before_action :get_change_log, only: %i[ show edit update ]

  # GET /activities or /activities.json
  def index
    @q = Activity.ransack(params[:q])
    if params.dig(:q, :phase)
      phase_id = params[:q][:phase].to_i
      activities_ids = PhasesActivity.where(phase_id: phase_id).pluck(:activity_id)
      @activities = Activity.where(id: activities_ids).paginate(page: params[:page], per_page: 3)
    else
      @activities = @q.result(distinct: true).order(updated_at: :desc).paginate(page: params[:page], per_page: 3)
    end
  end

  # GET /activities/1 or /activities/1.json
  def show
    redirect_to edit_activity_path(@activity)
  end

  # GET /activities/new
  def new
    @activity = Activity.new
    @activity.phases.build
  end

  # GET /activities/1/edit
  def edit
  end

  # POST /activities or /activities.json
  def create
    @activity = Activity.new(activity_params)

    validate_nested_phases

    respond_to do |format|
      if !@activity.errors.any? && @activity.save
        #create change log
        create_change_log

        format.html { redirect_to new_activity_path, notice: "Actividad de '#{User.find_by(id: @activity.user_id).get_short_name}' registrada correctamente." }
        format.json { render :show, status: :created, location: @activity }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /activities/1 or /activities/1.json
  def update
    validate_nested_phases

    #register change log
    @count = 1
    @phases_changes = false
    @phase_changes_description = ""
    validate_phases_changes

    respond_to do |format|
      if !@activity.errors.any? && @activity.update(activity_params)

        register_change_log

        format.html { redirect_to activity_url(@activity), notice: "Actividad de '#{User.find_by(id: @activity.user_id).get_short_name}' actualizada correctamente." }
        format.json { render :show, status: :ok, location: @activity }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /activities/1 or /activities/1.json
  def destroy
    respond_to do |format|
      format.html { redirect_to activity_url(@activity), alert: "No es permitido eliminar este registro." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_activity
      @activity = Activity.find(params[:id]) rescue nil

      if @activity.nil?
        redirect_to activities_path, alert: "La actividad a la que intenta acceder no existe."
      end
    end

    def set_collaborators
      @collaborators = User.where(role: "collaborator").order(fullname: :desc)
      @active_collaborators = User.where(role: "collaborator", status: "active").order(fullname: :desc)
    end

    def set_phases
      @phases = Phase.all
    end

    def set_projects 
      @projects = Project.all
      @open_projects = Project.where.not(stage: 8).order(name: :desc)
    end

    def get_change_log
      @activity_change_log = ChangeLog.where(table_id: @activity.id, table_name: "activity")
      if @activity_change_log.nil? || @activity_change_log.empty?
        @activity_change_log = nil
      end
    end

    def create_change_log
      description = "[#{Time.now.strftime("%d/%m/%Y - %H:%M")}] #{current_user.get_short_name} registra esta actividad."
      ChangeLog.new(table_id: @activity.id, user_id: current_user.id, description: description, table_name: "activity").save
    end

    def register_change_log
      changes = @activity.previous_changes

      @description = ""
      attribute_name = ""

      changes.each do |attribute, values|
        old_value, new_value = values
        
        case attribute
        when "project_id"
          attribute_name = "el proyecto"
          old_value = Project.find(old_value).name
          new_value = Project.find(new_value).name
        when "user_id"
          attribute_name = "el colaborador"
          old_value = User.find(old_value).get_short_name
          new_value = User.find(new_value).get_short_name
        when "date"
          attribute_name = "la fecha"
        end

        next if attribute_name.empty?

        @description = @description + "(#{@count}) Cambió #{attribute_name} de '#{old_value}' a '#{new_value}'. "
        attribute_name = ""
        @count += 1
      end
      
      @description = @description + @phase_changes_description if @phases_changes

      return if @description.empty?

      @description = "[#{Time.now.strftime("%d/%m/%Y - %H:%M")}] #{current_user.get_short_name} realizó los siguientes cambios: " + @description
      ChangeLog.new(table_id: @activity.id, user_id: current_user.id, description: @description, table_name: "activity").save
      @description = ""
    end

    def validate_nested_phases
      #validate if there are nested attributes
      if params[:activity][:phases_activities_attributes].nil? || params[:activity][:phases_activities_attributes].empty?
        @activity.errors.add(:phases_activities, "es necesario agregar al menos una actividad y horas realizadas")
        return
      end

      #Total hours validation
      total_hours_validation

      #Phase delete validation
      destroyed_phases_validation

      #Duplicate phases validation
      duplicate_phases_validation
    end

    def total_hours_validation
      nested_attributes = params[:activity][:phases_activities_attributes]
      total_hours = 0

      nested_attributes.each do |index, attributes|
        total_hours += attributes["hours"].to_i if attributes["_destroy"] == "false"
      end

      if total_hours < 1 || total_hours > 24
        @activity.errors.add(:phases_activities, "el total de horas debe estar entre 1 y 24")
      end
    end

    def destroyed_phases_validation
      #validate if all phases are marked to be destroyed
      if !@activity.new_record?
        deletedAssociations = 0
        nested_attributes = params[:activity][:phases_activities_attributes]

        nested_attributes.each do |index, attributes|
          @destroy_value = attributes["_destroy"]
          return true if @destroy_value == "false"
          deletedAssociations += 1
        end

        if @activity.phases_activities.count == deletedAssociations
          @activity.errors.add(:phases_activities, "es necesario agregar al menos una actividad y horas realizadas")
        end
      end
    end

    def duplicate_phases_validation
      nested_attributes = params[:activity][:phases_activities_attributes]
      return unless !nested_attributes.nil?

      phase_ids = []
      nested_attributes.each do |index, attributes|
        phase_ids << attributes["phase_id"] if attributes["_destroy"] == "false"
      end

      duplicates = phase_ids.select { |id| phase_ids.count(id) > 1 }.uniq
      if !duplicates.empty?
        @activity.errors.add(:phases_activities, "no puede haber actividades duplicadas")
      end
    end

    def validate_phases_changes
      return if @activity.errors.any?

      return if @activity.errors.any?
      new_attributes = params.fetch(:activity, {}).fetch(:phases_activities_attributes, {}).values
      removed_phases = new_attributes.select { |phase| phase[:_destroy] == "1"}

      if !removed_phases.empty?
        @phase_changes_description = @phase_changes_description + "(#{@count}) Eliminó las siguientes actividades: "
        removed_phases.each do |phase|
          current_phase = Phase.find_by(id: phase["phase_id"])
          next if current_phase.nil?
          @phase_changes_description = @phase_changes_description + "'#{current_phase.code} #{current_phase.name}' con '#{phase["hours"]}' horas, "
        end
        @phase_changes_description = @phase_changes_description.chomp(", ") + ". "
        @count += 1
        @phases_changes = true
      end

      new_phases = []
      nested_attributes = params[:activity][:phases_activities_attributes]
      nested_attributes.each do |index, phase|
        next if phase["_destroy"] == "1" || phase["phase_id"].nil?
        found = false
        @activity.phases_activities.each do |phase_activity|
          next if phase_activity.phase_id != phase["phase_id"].to_i
          found = true
        end
        new_phases << phase if !found
      end

      if !new_phases.empty?
        @phase_changes_description = @phase_changes_description + "(#{@count}) Agregó las siguientes actividades: "
        new_phases.each do |phase|
          current_phase = Phase.find_by(id: phase["phase_id"])
          next if current_phase.nil?
          @phase_changes_description = @phase_changes_description + "'#{current_phase.code} #{current_phase.name}' con '#{phase["hours"]}' horas, "
        end
        @phase_changes_description = @phase_changes_description.chomp(", ") + ". "
        @count += 1
        @phases_changes = true
      end
    end

    # Only allow a list of trusted parameters through.
    def activity_params
      params.require(:activity).permit(:worked_hours, :date, :user_id, :project_id, phases_activities_attributes: [:id, :phase_id, :hours, :_destroy])
    end
end
