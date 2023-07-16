class ProjectsController < ApplicationController
  # The `before_action` callback method ensures that the user is authenticated
  # before accessing any action in this controller. It helps enforce the requirement
  # for a user to be logged in before interacting with the `ProjectsController`.
  before_action :authenticate_user!

  # The `before_action` callback method `set_project` is called before the `show`, `edit`, `update`,
  # and `destroy` actions. It sets the `@project` instance variable by finding the project based on the
  # provided `id` parameter. If the project is not found, it redirects to the projects index page with an alert.
  before_action :set_project, only: %i[ show edit update destroy ]

  # The `before_action` callback method `set_admins` is called before the `index`, `new`, and `edit` actions.
  # It sets the `@admins` and `@all_admins` instance variables by finding all the users with the role of
  # `admin` and `collaborator` respectively. If no users are found, it sets the instance variables to `nil`.
  before_action :set_admins

  # The `before_action` callback method `get_change_log` is called before the `show`, `edit`, and `update` actions.
  # It sets the `@project_change_log` instance variable by finding all the change logs associated with the project.
  # If no change logs are found, it sets the instance variable to `nil`.
  before_action :get_change_log, only: %i[ show edit update ]

  # GET /projects or /projects.json

  # The `index` action is responsible for rendering the projects index view.
  # It retrieves all the projects and assigns them to the `@projects` instance variable.
  # It also retrieves the search parameters and assigns them to the `@q` instance variable.
  # The `@q` variable is used to filter the projects based on the search parameters.
  # It also retrieves the `active` parameter and filters the projects based on the `active` parameter.
  # If the `active` parameter is not present, it retrieves all the projects.
  # It also paginates the projects using the `paginate` method from the `will_paginate` gem.
  # The `paginate` method takes in two arguments: `page` and `per_page`.
  # The `page` argument is used to specify the page number of the paginated results.
  # The `per_page` argument is used to specify the number of projects to be displayed per page.
  # The `per_page` argument is set to `3` by default.
  # The `index` action also renders the `index` view.
  def index
    @q = Project.ransack(params[:q])

    if !params[:q].nil? && !params[:q][:active].nil?
      @projects = Project.where.not(stage: 8, stage_status: 2).order(updated_at: :desc).paginate(page: params[:page], per_page: 3)
      return
    end

    @projects = @q.result(distinct: true).order(updated_at: :desc).paginate(page: params[:page], per_page: 3)
  end

  def clear_filters
    redirect_to projects_path
  end

  # GET /projects/1 or /projects/1.json

  # The `show` action is responsible for rendering the projects show view.
  # It retrieves the project and assigns it to the `@project` instance variable.
  # It also renders the `show` view.
  def show
    redirect_to edit_project_path(@project)
  end

  # GET /projects/new

  # The `new` action is responsible for rendering the projects new view.
  # It initializes a new project and assigns it to the `@project` instance variable.
  # It also renders the `new` view.
  def new
    @project = Project.new
  end

  # GET /projects/1/edit

  # The `edit` action is responsible for rendering the projects edit view.
  # It retrieves the project and assigns it to the `@project` instance variable.
  # It also renders the `edit` view.
  def edit
  end

  # POST /projects or /projects.json

  # The `create` action is responsible for creating a new project.
  # It initializes a new project with the project parameters and assigns it to the `@project` instance variable.
  # It then attempts to save the project to the database.
  # If the project is successfully saved, it redirects to the projects show page with a notice.
  # If the project is not successfully saved, it renders the `new` view with an unprocessable entity error.
  # The `create` action also calls the `create_change_log` method to create a change log for the project.
  # The `create_change_log` method is defined below.
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

  # The `update` action is responsible for updating an existing project.
  # It retrieves the project and assigns it to the `@project` instance variable.
  # It then attempts to update the project with the project parameters.
  # If the project is successfully updated, it redirects to the projects show page with a notice.
  # If the project is not successfully updated, it renders the `edit` view with an unprocessable entity error.
  # The `update` action also calls the `register_change_log` method to register the change log for the project.
  # The `register_change_log` method is defined below.
  def update
    if params[:project][:stage] == "finished"
      params[:project][:stage_status] = "delivered"
    end

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

  # The `destroy` action is responsible for deleting an existing project.
  # It retrieves the project and assigns it to the `@project` instance variable.
  # It then attempts to delete the project.
  # If the project is successfully deleted, it redirects to the projects index page with a notice.
  # If the project is not successfully deleted, it redirects to the projects index page with an alert.
  # The `destroy` action also checks if the project has associated minutes and activities.
  # If the project has associated minutes and activities, it redirects to the projects index page with an alert.
  # If the project does not have associated minutes and activities, it deletes the project.
  def destroy
    @project.destroy if !@project.has_associated_minutes_and_activities?

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

    # The `set_project` method is used to set the `@project` instance variable.
    # It finds the project based on the provided `id` parameter.
    # If the project is not found, it redirects to the projects index page with an alert.
    def set_project
      @project = Project.find(params[:id]) rescue nil

      if @project.nil?
        redirect_to projects_path, alert: "El proyecto al que intenta acceder no existe."
      end
    end

    # The `set_admins` method is used to set the `@admins` and `@all_admins` instance variables.
    # It finds all the users with the role of `admin` and `collaborator` respectively.
    # If no users are found, it sets the instance variables to `nil`.
    def set_admins
      @admins = User.where(role: "admin", status: "active").order(fullname: :desc)
      @all_admins = User.where(role: "admin").order(fullname: :desc)
    end

    # The `get_change_log` method is used to set the `@project_change_log` instance variable.
    # It finds all the change logs associated with the project.
    # If no change logs are found, it sets the instance variable to `nil`.
    def get_change_log
      @project_change_log = ChangeLog.where(table_id: @project.id, table_name: "project").order(created_at: :desc)
      if @project_change_log.empty? || @project_change_log.nil?
        @project_change_log = nil
      end
    end

    # The `register_change_log` method is used to register the change log for the project.
    # It retrieves the changes made to the project and creates a change log for each change.
    # It also sets the description for each change log.
    # The `register_change_log` method is called in the `update` action.

    # It sets the `table_id`, `user_id`, `description`, and `table_name` parameters.
    # The `table_id` parameter is set to the project id.
    # The `user_id` parameter is set to the current user id.
    # The `description` parameter is set to the description of the change log.
    # The `table_name` parameter is set to `project`.
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

      return if description.empty?

      author = current_user.get_short_name
      current_time = Time.now.strftime("%d/%m/%Y - %H:%M")
      description = "[#{current_time}] #{author} realizó los siguientes cambios: #{description}"
      ChangeLog.new(table_id: @project.id, user_id: current_user.id, description: description, table_name: "project").save
      description = ""
    end

    # The `create_change_log` method is used to create a change log for the project.
    # It sets the description for the change log.
    # The `create_change_log` method is called in the `create` action.
    def create_change_log
      description = "[#{Time.now.strftime("%d/%m/%Y - %H:%M")}] #{current_user.get_short_name} crea este proyecto."
      ChangeLog.new(table_id: @project.id, user_id: current_user.id, description: description, table_name: "project").save
    end

    # Only allow a list of trusted parameters through.
    def project_params
      params.require(:project).permit(:name, :start_date, :scheduled_deadline, :location, :stage, :stage_status, :user_id)
    end
end
