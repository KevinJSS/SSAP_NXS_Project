class MinutesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_minute, only: %i[ show edit update destroy ]
  before_action :set_attendees, :set_projects

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
          @destroy_value = attributes["_destroy"]
          return true if @destroy_value == "false"
          deletedAssociations += 1
        end

        if @minute.minutes_users.count == deletedAssociations
          @minute.errors.add(:minutes_users, "es necesario seleccionar al menos un asistente")
          false
        end
      end
    end

    def duplicate_attendees_validation
      nested_attributes = params[:minute][:minutes_users_attributes]
      
      user_ids = []
      nested_attributes.each do |index, attributes|
        user_ids << attributes["user_id"] if attributes["_destroy"] == "false"
      end

      duplicates = user_ids.select { |id| user_ids.count(id) > 1 }.uniq
      if !duplicates.empty?
        @minute.errors.add(:minutes_users, "no puede haber asistentes duplicados")
      end
    end

    # Only allow a list of trusted parameters through.
    def minute_params
      params.require(:minute).permit(:meeting_title, :meeting_date, :start_time, :end_time, :meeting_objectives, :discussed_topics, :pending_topics, :agreements, :meeting_notes, :project_id, minutes_users_attributes: [:id, :user_id, :_destroy])
    end
end
