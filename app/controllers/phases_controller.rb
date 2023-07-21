class PhasesController < ApplicationController
  # The 'authenticate_user!' method is used to authenticate the user before executing the specified actions.
  before_action :authenticate_user!

  # The 'set_phase' method is used to set the phase before executing the specified actions.
  before_action :set_phase, only: %i[ show edit update destroy ]

  # The 'get_change_log' method is used to get the change log of the phase before executing the specified actions.
  before_action :get_change_log, only: %i[ show edit update ]

  # GET /phases or /phases.json

  # The 'index' method is used to get all the phases.
  # The 'ransack' gem is used to search, sort and filter the phases.
  # The 'paginate' method is used to split the phases into pages containing a specified number of phases.
  def index
    @q = Phase.ransack(params[:q])
    @phases = @q.result(distinct: true).paginate(page: params[:page], per_page: 5)
  end

  # GET /phases/1 or /phases/1.json

  # The 'show' method is used to get a phase from the database by the id passed in the params.
  # And redirect to the edit phase page to show the phase.
  def show
    redirect_to edit_phase_path(@phase)
  end

  # GET /phases/new

  # The 'new' method is used to create a new phase.
  # And retrieve the new phase object to the new phase view.
  def new
    @phase = Phase.new
  end

  # GET /phases/1/edit

  # The 'edit' method is used to get a phase from the database by the id passed in the params.
  # And retrieve the phase object to the edit phase view.
  def edit
  end

  # POST /phases or /phases.json

  # The `create` action is responsible for creating a new phase.
  # It initializes a new phase with the phase parameters and assigns it to the `@phase` instance variable.
  # It then attempts to save the phase to the database.
  # If the phase is successfully saved, it redirects to the phases show page with a notice.
  # If the phase is not successfully saved, it renders the `new` view with an unprocessable entity error.
  # The `create` action also calls the `create_change_log` method to create a change log for the phase.
  # The `create_change_log` method is defined below.
  def create
    @phase = Phase.new(phase_params)

    respond_to do |format|
      if @phase.save
        create_change_log

        format.html { redirect_to phase_url(@phase), notice: "Fase agregada correctamente." }
        format.json { render :show, status: :created, location: @phase }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @phase.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /phases/1 or /phases/1.json

  # The `update` action is responsible for updating an existing phase.
  # It retrieves the phase from the database using the id passed in the params.
  # It then attempts to update the phase with the phase parameters.
  # If the phase is successfully updated, it redirects to the phases show page with a notice.
  # If the phase is not successfully updated, it renders the `edit` view with an unprocessable entity error.
  # The `update` action also calls the `register_change_log` method to register a change log for the phase.
  # The `register_change_log` method is defined below.
  def update
    respond_to do |format|
      if @phase.update(phase_params)
        register_change_log

        format.html { redirect_to phase_url(@phase), notice: "Fase actualizada correctamente." }
        format.json { render :show, status: :ok, location: @phase }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @phase.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /phases/1 or /phases/1.json

  # The `destroy` action is responsible for deleting an existing phase.
  # It retrieves the phase from the database using the id passed in the params.
  # It then attempts to delete the phase.
  # If the phase is successfully deleted, it redirects to the phases index page with a notice.
  # If the phase is not successfully deleted, it redirects to the phases index page with an alert.
  def destroy
    @phase.destroy if @phase.activities.count == 0

    respond_to do |format|
      if @phase.activities.count == 0
        format.html { redirect_to phases_url, notice: "Fase '#{@phase.name}' eliminada correctamente." }
        format.json { head :no_content }
      else
        format.html { redirect_to phases_url, alert: "No se puede eliminar la fase porque tiene actividades asociadas." }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.

    # The `set_phase` method is used to set the phase before executing the specified actions.
    # It retrieves the phase from the database using the id passed in the params.
    # If the phase does not exist, it redirects to the phases index page with an alert.
    def set_phase
      @phase = Phase.find(params[:id]) rescue nil

      if @phase.nil?
        redirect_to phases_path, alert: "La fase a la que intenta acceder no existe."
      end
    end

    # The `get_change_log` method is used to get the change log of the phase before executing the specified actions.
    # It retrieves the change log of the phase from the database using the id passed in the params.
    # If the phase does not have a change log, it sets the change log to nil.
    def get_change_log
      @phase_change_log = ChangeLog.where(table_name: 'phase', table_id: @phase.id).order(created_at: :desc)
      if @phase_change_log.empty? || @phase_change_log.nil?
        @phase_change_log = nil
      end
    end

    # The `create_change_log` method is used to create a change log for the phase.
    # It creates a new change log with the user id, table id, description and table name.
    # The `current_user` method is used to get the current user.
    # The `get_short_name` method is used to get the short name of the current user.
    # The `save` method is used to save the change log to the database.
    def create_change_log
      description = "[#{Time.now.strftime("%d/%m/%Y - %H:%M")}] #{current_user.get_short_name} crea esta fase."
      ChangeLog.new(table_id: @phase.id, user_id: current_user.id, description: description, table_name: "phase").save
    end

    # The `register_change_log` method is used to register a change log for the phase.
    # It retrieves the changes of the phase.
    # It then iterates through the changes and creates a description of the changes.
    # The `current_user` method is used to get the current user.
    # The `get_short_name` method is used to get the short name of the current user.
    # The `save` method is used to save the change log to the database.
    def register_change_log
      changes = @phase.previous_changes

      description = ""
      attribute_name = ""
      count = 1

      changes.each do |attribute, values|
        old_value, new_value = values

        case attribute
        when "code"
          attribute_name = "el código"
          old_value = old_value.strip if !old_value.nil?
          new_value = new_value.strip if !new_value.nil?
          next if old_value == new_value

        when "name"
          attribute_name = "el nombre"
          old_value = old_value.strip if !old_value.nil?
          new_value = new_value.strip if !new_value.nil?
          next if old_value == new_value
        end

        if attribute_name.empty? then next end

        description << "(#{count}) Cambió #{attribute_name} de '#{old_value}' a '#{new_value}'. "
        attribute_name = ""
        count += 1
      end

      return if description.empty?

      description = "[#{Time.now.strftime("%d/%m/%Y - %H:%M")}] #{current_user.get_short_name} realizó los siguientes cambios: #{description}"
      ChangeLog.new(table_id: @phase.id, user_id: current_user.id, description: description, table_name: "phase").save
      description = ""
    end

    # Only allow a list of trusted parameters through.
    def phase_params
      params.require(:phase).permit(:code, :name)
    end
end
