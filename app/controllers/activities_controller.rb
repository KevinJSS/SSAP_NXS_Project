class ActivitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_activity, only: %i[ show edit update destroy ]
  before_action :set_collaborators, :set_projects, :set_phases

  # GET /activities or /activities.json
  def index
    @activities = Activity.paginate(page: params[:page], per_page: 3)
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
        format.html { redirect_to new_activity_path, notice: "Activity was successfully created." }
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

    respond_to do |format|
      if !@activity.errors.any? && @activity.update(activity_params)
        format.html { redirect_to activity_url(@activity), notice: "Activity was successfully updated." }
        format.json { render :show, status: :ok, location: @activity }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /activities/1 or /activities/1.json
  def destroy
    @activity.destroy

    respond_to do |format|
      format.html { redirect_to activities_url, notice: "Activity was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_activity
      @activity = Activity.find(params[:id])
    end

    def set_collaborators
      @collaborators = User.where(role: 0)
      #@collaborators = User.all
    end

    def set_phases
      @phases = Phase.all
    end

    def set_projects 
      @projects = Project.all
    end

    def validate_nested_phases
      #validate if there are nested attributes
      if params[:activity][:phases_activities_attributes].nil? || params[:activity][:phases_activities_attributes].empty?
        @activity.errors.add(:phases_activities, "es necesario seleccionar al menos una fase y horas realizadas")
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
          @activity.errors.add(:phases_activities, "es necesario seleccionar al menos una fase y horas realizadas")
        end
      end
    end

    def duplicate_phases_validation
      nested_attributes = params[:activity][:phases_activities_attributes]

      phase_ids = []
      nested_attributes.each do |index, attributes|
        phase_ids << attributes["phase_id"] if attributes["_destroy"] == "false"
      end

      duplicates = phase_ids.select { |id| phase_ids.count(id) > 1 }.uniq
      if !duplicates.empty?
        @activity.errors.add(:phases_activities, "no puede haber fases duplicadas")
      end
    end

    # Only allow a list of trusted parameters through.
    def activity_params
      params.require(:activity).permit(:worked_hours, :date, :user_id, :project_id, phases_activities_attributes: [:id, :phase_id, :hours, :_destroy])
    end
end
