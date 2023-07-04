class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: %i[ show edit update destroy ]
  before_action :set_admins
  before_action :get_change_log, only: %i[ show edit update ]

  # GET /projects or /projects.json
  def index
    @projects = Project.order(updated_at: :desc).paginate(page: params[:page], per_page: 3)
  end

  # GET /projects/1 or /projects/1.json
  def show
    redirect_to edit_project_path(@project)
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects or /projects.json
  def create
    @project = Project.new(project_params)

    respond_to do |format|
      if @project.save
        # create the change log
        create_change_log

        format.html { redirect_to project_url(@project), notice: "Proyecto agregado correctamente." }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1 or /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        # Register the change log
        register_change_log

        format.html { redirect_to project_url(@project), notice: "Proyecto actualizado correctamente." }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1 or /projects/1.json
  def destroy
    @project.destroy if !@project.has_associated_minutes_and_activities?
    ChangeLog.where(table_id: @project.id, table_name: "project").destroy_all

    respond_to do |format|
      if @project.has_associated_minutes_and_activities?
        format.html { redirect_to projects_url, alert: "No se puede eliminar el proyecto porque tiene minutas y/o actividades asociadas." }
        format.json { head :no_content }
      else
        format.html { redirect_to projects_url, notice: "Proyecto '#{@project.name}' eliminado correctamente." }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id]) rescue nil

      if @project.nil?
        redirect_to projects_path, alert: "El proyecto al que intenta acceder no existe."
      end
    end

    def set_admins
      @admins = User.where(role: "admin", status: "active").order(fullname: :desc)
    end

    def get_change_log
      @project_change_log = ChangeLog.where(table_id: @project.id, table_name: "project")
      if @project_change_log.empty? || @project_change_log.nil?
        @project_change_log = nil
      end
    end

    def register_change_log
      changes = @project.previous_changes

      description = ""
      attribute_name = ""
      count = 1

      changes.each do |attribute, values|
        old_value, new_value = values

        case attribute
        when "name"
          attribute_name = "el nombre"
        when "start_date"
          attribute_name = "la fecha de inicio"
        when "scheduled_deadline"
          attribute_name = "la fecha de cierre"
        when "location"
          attribute_name = "la ubicación"
        when "stage"
          attribute_name = "la etapa"
          old_value = @project.get_humanize_stage(old_value)
          new_value = @project.get_humanize_stage(new_value)
        when "stage_status"
          attribute_name = "el estado"
          old_value = @project.get_humanize_status(old_value)
          new_value = @project.get_humanize_status(new_value)
        when "user_id"
          attribute_name = "el/la encargado/a"
          old_value = User.find(old_value).get_short_name
          new_value = User.find(new_value).get_short_name
        end

        if attribute_name.empty? then next end

        description << "(#{count}) Cambió #{attribute_name} de '#{old_value.to_s.humanize}' a '#{new_value.to_s.humanize}'. "
        attribute_name = ""
        count += 1
      end

      # Construir el registro del cambio
      return if description.empty?

      author = current_user.get_short_name
      current_time = Time.now.strftime("%d/%m/%Y - %H:%M")
      description = "[#{current_time}] #{author} realizó los siguientes cambios: #{description}"
      ChangeLog.new(table_id: @project.id, user_id: current_user.id, description: description, table_name: "project").save
      description = ""
    end

    def create_change_log
      description = "[#{Time.now.strftime("%d/%m/%Y - %H:%M")}] #{current_user.get_short_name} crea este proyecto."
      ChangeLog.new(table_id: @project.id, user_id: current_user.id, description: description, table_name: "project").save
    end

    # Only allow a list of trusted parameters through.
    def project_params
      params.require(:project).permit(:name, :start_date, :scheduled_deadline, :location, :stage, :stage_status, :user_id)
    end
end
