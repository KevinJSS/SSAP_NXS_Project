class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: %i[ show edit update destroy ]
  before_action :set_admins, :set_stages_options, :set_status_options
  before_action :get_stage_and_status, only: %i[ show edit update]

  # GET /projects or /projects.json
  def index
    @projects = Project.all
  end

  # GET /projects/1 or /projects/1.json
  def show
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
        format.html { redirect_to project_url(@project), notice: "Project was successfully created." }
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
        format.html { redirect_to project_url(@project), notice: "Project was successfully updated." }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1 or /projects/1.json
  def destroy
    @project.destroy

    respond_to do |format|
      format.html { redirect_to projects_url, notice: "Project was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    def set_admins
      @admins = User.where(role: 1)
    end

    def set_stages_options
      @stage_options = [
        ["Diseño conceptual", :conceptual_design],
        ["Diseño arquitectónico", :arch_design],
        ["Diseño de ingeniería", :eng_design],
        ["Permisos y aprovaciones", :approvals],
        ["Licitación y contratación", :contracting],
        ["Construcción", :construction],
        ["Finalización y entrega", :completion_delivery]
      ]
    end

    def set_status_options
      @stage_status_options = [
        ["Pendiente", :pending],
        ["En proceso", :in_process],
        ["Aprobado", :approved],
        ["Rechazado", :denied],
        ["Finalizado", :finished]
      ]
    end

    def get_stage_and_status
      @stage_options.each do |stage|
        @stage = stage[0] if stage[1].to_s == @project.stage 
      end

      @stage_status_options.each do |status|
        @status = status[0] if status[1].to_s == @project.stage_status 
      end
    end

    # Only allow a list of trusted parameters through.
    def project_params
      params.require(:project).permit(:name, :start_date, :scheduled_deadline, :location, :stage, :stage_status, :user_id)
    end
end
