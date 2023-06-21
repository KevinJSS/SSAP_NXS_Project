class MinutesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_minute, only: %i[ show edit update destroy ]
  before_action :set_attendees, :set_projects

  # GET /minutes or /minutes.json
  def index
    @minutes = Minute.all
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
      if params[:minute][:minutes_users_attributes].nil? || params[:minute][:minutes_users_attributes].empty?
        @minute.errors.add(:minutes_users, "es necesario seleccionar al menos un asistente")
      end

      if !@minute.new_record?
        #validate if all phases are marked to be destroyed
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

    # Only allow a list of trusted parameters through.
    def minute_params
      params.require(:minute).permit(:meeting_title, :meeting_date, :start_time, :end_time, :meeting_objectives, :discussed_topics, :pending_topics, :agreements, :meeting_notes, :project_id, minutes_users_attributes: [:id, :user_id, :_destroy])
    end
end
