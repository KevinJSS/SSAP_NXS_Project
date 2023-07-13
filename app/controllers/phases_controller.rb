class PhasesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_phase, only: %i[ show edit update destroy ]
  before_action :get_change_log, only: %i[ show edit update ]

  # GET /phases or /phases.json
  def index
    @q = Phase.ransack(params[:q])
    @phases = @q.result(distinct: true).paginate(page: params[:page], per_page: 3)
  end

  # GET /phases/1 or /phases/1.json
  def show
    redirect_to edit_phase_path(@phase)
  end

  # GET /phases/new
  def new
    @phase = Phase.new
  end

  # GET /phases/1/edit
  def edit
  end

  # POST /phases or /phases.json
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
    def set_phase
      @phase = Phase.find(params[:id]) rescue nil

      if @phase.nil?
        redirect_to phases_path, alert: "La fase a la que intenta acceder no existe."
      end
    end

    def get_change_log
      @phase_change_log = ChangeLog.where(table_name: 'phase', table_id: @phase.id).order(created_at: :desc)
      if @phase_change_log.empty? || @phase_change_log.nil?
        @phase_change_log = nil
      end
    end

    def create_change_log
      description = "[#{Time.now.strftime("%d/%m/%Y - %H:%M")}] #{current_user.get_short_name} crea esta fase."
      ChangeLog.new(table_id: @phase.id, user_id: current_user.id, description: description, table_name: "phase").save
    end

    def register_change_log
      changes = @phase.previous_changes

      description = ""
      attribute_name = ""
      count = 1

      changes.each do |attribute, values|
        old_value, new_value = values
        old_value = old_value.strip if !old_value.nil?
        new_value = new_value.strip if !new_value.nil?

        case attribute
        when "code"
          attribute_name = "el código"
        when "name"
          attribute_name = "el nombre"
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
