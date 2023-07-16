class ActivitiesController < ApplicationController
  # The `before_action` callback method ensures that the user is authenticated
  # before accessing any action in this controller. It helps enforce the requirement
  # for a user to be logged in before interacting with the `ProjectsController`.
  before_action :authenticate_user!

  # The `before_action` callback method 'set_activity' is used to set the activity
  # instance variable before calling the `show`, `edit`, `update` and `destroy` methods.
  # Except for the `activities_report` method, which is used to generate the activities report.
  before_action :set_activity, only: %i[show edit update destroy], except: :activities_report

  # The `before_action` callback method 'set_collaborators' is used to set the collaborators
  # instance variable before calling the `new`, `create`, `edit` and `update` methods.
  before_action :set_collaborators, :set_projects, :set_phases

  # The `before_action` callback method 'get_change_log' is used to set the activity_change_log
  # instance variable before calling the `show`, `edit` and `update` methods.
  before_action :get_change_log, only: %i[ show edit update ]

  # GET /activities or /activities.json

  # The `index` action is responsible for rendering the activities index view.
  # It retrieves all the activities and assigns them to the `@activities` instance variable.
  # It also retrieves the search parameters and assigns them to the `@q` instance variable.
  # The `@q` variable is used to filter the activities based on the search parameters.
  # It retrieves the search parameters from the `params` hash. And it uses the `ransack` gem
  # to filter the activities based on the search parameters.
  # It also paginates the projects using the `paginate` method from the `will_paginate` gem.
  # The `paginate` method takes in two arguments: `page` and `per_page`.
  # The `page` argument is used to specify the page number of the paginated results.
  # The `per_page` argument is used to specify the number of projects to be displayed per page.
  # The `per_page` argument is set to `3` by default.
  # The `index` action also renders the `index` view.
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

  # The `show` action is responsible for rendering the activities show view.
  # It retrieves the activity and assigns it to the `@activity` instance variable.
  # And redirects to the `edit` action.
  def show
    redirect_to edit_activity_path(@activity)
  end

  # GET /activities/new
  
  # The `new` action is responsible for rendering the `new` view.
  # It initializes a new activity and assigns it to the `@activity` instance variable.
  # It also initializes a new phases_activity and assigns it to the `@phases_activity` instance variable.
  def new
    @activity = Activity.new
    @activity.phases.build
  end

  # GET /activities/1/edit

  # The `edit` action is responsible for rendering the `edit` view.
  # It retrieves the activity and assigns it to the `@activity` instance variable.
  def edit
  end

  # POST /activities_report

  # The `activities_report` action is responsible for generating the activities report.
  #
  # This action receives parameters to determine the type of report and the date range. It performs
  # validation checks on the provided parameters and generates the report accordingly. Here is a detailed
  # breakdown of the code:
  #
  # 1. Retrieve the `report_type` parameter from the request.
  # 2. Check if the `report_type` is provided. If not, redirect to the activities path with an alert message.
  # 3. Retrieve the `start_date` and `end_date` parameters from the request.
  # 4. Check if both `start_date` and `end_date` are provided. If either is missing, redirect to the activities path with an alert message.
  # 5. Validate the date range by calling the `valid_date_range` method. If the range is invalid, the method handles the necessary redirects and alerts.
  # 6. Generate the report based on the provided `report_type`.
  #    - If the `report_type` is "collaborator," call the `collaborator_report` method with the `start_date` and `end_date` parameters.
  #    - If the `report_type` is "general," call the `general_report` method with the `start_date` and `end_date` parameters.
  #
  # It's important to note that the implementation details of the `collaborator_report` and `general_report` methods are not shown here,
  # but these methods are defined below.
  def activities_report
    report_type = params[:report_type]

    if report_type.nil?
      redirect_to activities_path, alert: "Es necesario indicar el tipo de reporte de reporte que se desea generar."
      return
    end

    start_date = params[:start_date]
    end_date = params[:end_date]

    if start_date.empty? || end_date.empty?
      redirect_to activities_path, alert: "Es necesario indicar el rango de fechas para generar el reporte."
      #flash[:alert] = "Es necesario indicar el rango de fechas para generar el reporte."
      return
    end

    return if !valid_date_range(start_date, end_date)

    case report_type
      when "collaborator"
        collaborator_report(start_date, end_date)
      when "general"
        general_report(start_date, end_date)
    end
  end

  # POST /activities or /activities.json

  # The `create` action is responsible for creating a new activity with the provided parameters.
  #
  # This action handles the creation of a new activity based on the submitted form data. Here is a detailed breakdown of the code:
  #
  # 1. Create a new instance of the `Activity` model using the `activity_params` method to whitelist and retrieve the permitted parameters.
  # 2. Perform validation checks on nested phases by calling the `validate_nested_phases` method.
  # 3. Perform validation checks on previous activities by calling the `validate_previous_activities` method.
  # 4. Use a `respond_to` block to handle the response format (HTML or JSON).
  # 5. Check if there are no errors and the activity can be successfully saved to the database.
  #    - If there are no errors and the activity is saved, proceed to create a change log by calling the `create_change_log` method.
  #    - Redirect to the `new_activity_path` with a success notice in the HTML response.
  #    - Render the created activity in the JSON response with a status of 201 (created).
  # 6. If there are errors, render the `new` view template with a status of 422 (unprocessable entity) in the HTML response.
  #    - Render the errors as JSON in the JSON response with a status of 422.
  #
  # It's important to note that the implementation details of the `activity_params`, `validate_nested_phases`, `validate_previous_activities`,
  # and `create_change_log` methods are not shown here, but these methods are defined below.
  def create
    @activity = Activity.new(activity_params)

    validate_nested_phases
    validate_previous_activities

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

  # The `update` action is responsible for updating an existing activity with the provided parameters.
  #
  # This action handles the update of an existing activity based on the submitted form data. Here is a detailed breakdown of the code:
  # 
  # 1. Perform validation checks on nested phases by calling the `validate_nested_phases` method.
  # 2. Perform validation checks on previous activities by calling the `validate_previous_activities` method.
  # 3. Use a `respond_to` block to handle the response format (HTML or JSON).
  # 4. Check if there are no errors and the activity can be successfully updated in the database.
  #   - If there are no errors and the activity is updated, proceed to create a change log by calling the `register_change_log` method.
  #   - Redirect to the `activity_path` with a success notice in the HTML response.
  #   - Render the updated activity in the JSON response with a status of 200 (ok).
  # 5. If there are errors, render the `edit` view template with a status of 422 (unprocessable entity) in the HTML response.
  #   - Render the errors as JSON in the JSON response with a status of 422.
  #
  # It's important to note that the implementation details of the `validate_nested_phases`, `validate_previous_activities`, and `register_change_log`
  # methods are not shown here, but these methods are defined below.
  def update
    validate_nested_phases
    validate_previous_activities

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
  
  # The `destroy` action is responsible for deleting an existing activity.
  # In this case, the `destroy` action is not allowed. So, it redirects to the `activity_path` with an alert message.
  def destroy
    respond_to do |format|
      format.html { redirect_to activity_url(@activity), alert: "No es permitido eliminar este registro." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.

    # The `set_activity' method is used to set the activity instance variable before calling the `show`, `edit`, `update` and `destroy` methods.
    # It retrieves the activity from the database using the `params` hash.
    # If the activity is not found, it redirects to the `activities_path` with an alert message.
    def set_activity
      @activity = Activity.find(params[:id]) rescue nil

      if @activity.nil?
        redirect_to activities_path, alert: "La actividad a la que intenta acceder no existe."
      end
    end

    # This method is responsible for validating the previous activities before saving the current activity.
    #
    # Here is a breakdown of the code:
    #
    # 1. Check if there are any errors in the current activity. If there are errors, no further validation is performed.
    # 2. Determine if the date of the activity has been changed compared to the original date.
    # 3. Retrieve all activities for the same user and date as the current activity.
    # 4. If no activities are found or the activities variable is nil, no further validation is performed.
    # 5. Initialize variables to track the new and previous hours.
    # 6. Calculate the previous hours by iterating through each activity and its associated phases_activities.
    # 7. If the current activity is new, calculate the new hours by iterating through its phases_activities.
    # 8. If the current activity is not new, compare the nested attributes with the existing phases_activities.
    #    - If the date has not changed, adjust the previous and new hours based on the _destroy flag and the existence of the phase in the database.
    #    - If the date has changed, only consider the new hours for validation.
    # 9. Validate if the total hours (previous + new) exceed 24. If so, add an error to the activity.
    #
    # It's worth noting that the code references various attributes and associations, such as @activity, params, phases_activities,
    # and the date formatting method l() to format the date using the predefined formats in the locale file.
    def validate_previous_activities
      return if @activity.errors.any?

      date_changed = @activity.date != params[:activity][:date].to_date
      activities = Activity.where(user_id: @activity.user_id, date: params[:activity][:date].to_date)

      return if activities.empty? || activities.nil?

      new_hours = 0
      previous_hours = 0

      # load up the previous hours
      activities.each do |activity|
        activity.phases_activities.each do |phase_activity|
          previous_hours += phase_activity.hours
        end
      end

      if @activity.new_record?
        # if the activity is new, then add its hours to the new hours
        @activity.phases_activities.each do |phase_activity|
          new_hours += phase_activity.hours
        end
      else
        nested_attributes = params[:activity][:phases_activities_attributes]
        phases_activities = @activity.phases_activities

        if !date_changed
          nested_attributes.each do |index, attributes|
            phase_id = attributes["phase_id"].to_i
            phase_activity = phases_activities.find_by(phase_id: phase_id)
  
            if attributes["_destroy"] == "1" && phase_activity
              # if the phase is marked to be destroyed and exists in the database, then subtract its hours from the previous hours
              previous_hours -= attributes["hours"].to_d
            elsif attributes["_destroy"] == "false" && !phase_activity
              # if the phase is not marked to be destroyed and does not exist in the database, then add its hours to the new hours
              new_hours += attributes["hours"].to_d
            end
          end
        else
          nested_attributes.each do |index, attributes|
            if attributes["_destroy"] == "false"
              # if the phase is not marked to be destroyed, then add its hours to the new hours
              new_hours += attributes["hours"].to_d
            end
          end
        end
      end

      # validate if the total hours are greater than 24
      if previous_hours + new_hours > 24
        @activity.errors.add(:phases_activities, "el total de horas registradas para el día #{l(@activity.date, format: :long)} es mayor a 24 horas")
      end
    end

    # The collaborator_report method is responsible for generating the collaborator report. 
    #
    # This method receives the start_date and end_date parameters and performs validation checks on the provided parameters.
    # If the parameters are valid, it generates the collaborator report. Here is a detailed breakdown of the code:
    #
    # 1. Retrieve the collaborator from the database using the `params` hash.
    # 2. If the collaborator is not found, redirect to the activities path with an alert message.
    # 3. Retrieve the activities for the collaborator in the date range.
    # 4. If no activities are found or the activities variable is nil, redirect to the activities path with an alert message.
    # 5. Retrieve the collaborator_report_type parameter from the request.
    # 6. If the collaborator_report_type is not provided, redirect to the activities path with an alert message.
    # 7. Call the `generate_collaborator_report` method with the activities, collaborator, start_date, end_date, and collaborator_report_type parameters.
    #
    # Its important to note that the implementation details of the `generate_collaborator_report` method are not shown here,
    # but this method is defined below.
    def collaborator_report(start_date, end_date)
      collaborator = User.find_by(id: params[:user_id])
  
      if collaborator.nil?
        redirect_to activities_path, alert: "Es necesario indicar el colaborador para generar el reporte."
        #flash[:alert] = "Es necesario indicar el colaborador para generar el reporte."
        return
      end
  
      activities = Activity.where(date: start_date..end_date, user_id: collaborator.id).order(date: :asc)
      
      if activities.nil? || activities.empty?
        redirect_to activities_path, alert: "No se encontraron actividades registradas para este colaborador en el periodo de tiempo ingresado."
        return
      end
  
      collaborator_report_type = params[:collaborator_report_type]
  
      if collaborator_report_type.nil? || collaborator_report_type.empty?
        flash[:alert] = "Es necesario indicar el tipo de reporte del colaborador que se desea generar."
        return
      end
  
      generate_collaborator_report(activities, collaborator, start_date, end_date, collaborator_report_type)
    end
  
    # The `generate_collaborator_report` method is responsible for generating the collaborator report.
    #
    # Here is a breakdown of the code:
    #
    # 1. Group activities by project using the `group_by` method.
    # 2. Calculate the total report hours by summing the hours of all activities and their associated phases.
    # 3. Group the phases activities count and sum by project using the `get_grouped_phases` method.
    # 4. Initialize a new Prawn PDF document.
    # 5. Add logos to the header and footer of the PDF.
    # 6. Define the body of the PDF.
    #    - Set the report title based on the collaborator report type.
    #    - Add collaborator information to the PDF.
    #    - Add report information such as date range, total hours, etc.
    #    - If the collaborator report type is "detailed":
    #      - Generate a detailed activities table for each project, showing the activities and their associated phases.
    #      - Calculate the total hours for each project.
    #    - Generate a summary table of activities by phase for each project.
    # 7. Add a footer to the PDF.
    # 8. Render the PDF and send it as a response with a unique filename based on the collaborator and report details.
    #
    # It's worth noting that the code references various attributes and associations, such as activities, collaborator, start_date, end_date, etc.
    # These parts of the code are not shown here, but they are defined in the collaborator_report method above.
    #
    # The method uses additional helper methods to format the PDF, such as pdf_logos, pdf_document_title, pdf_subtitle, pdf_formatted_text,
    # pdf_section_heading, pdf_table, pdf_summary_phases_table, pdf_footer, etc. These methods are defined below.
    def generate_collaborator_report(activities, collaborator, start_date, end_date, collaborator_report_type)
      # Activities grouped by project
      activities_grouped_by_project = activities.group_by(&:project_id)
      # Total report hours
      total_report_hours = activities.sum { |activity| activity.phases_activities.sum(&:hours) }
      # Phases activities grouped count and sum by project
      phases_hours_group_by_project = get_grouped_phases(activities_grouped_by_project)
      
      require 'prawn'
      require 'prawn/table'
  
      pdf = Prawn::Document.new
  
      # Header and footer logos
      pdf_logos(pdf)
  
      # Body
      pdf.bounding_box([pdf.bounds.left, pdf.bounds.top - 50], width: pdf.bounds.width, height: pdf.bounds.height - 120) do
        # PDF header
        report_title = collaborator_report_type == "summary" ? "REPORTE RESUMIDO DE ACTIVIDADES POR COLABORADOR" : "REPORTE DETALLADO DE ACTIVIDADES\nPOR COLABORADOR"
        pdf_document_title(pdf, report_title)
  
        # Collaborator info
        pdf_subtitle(pdf, "Información del colaborador")
        pdf_formatted_text(pdf, "Nombre completo: ", collaborator.fullname)
        pdf_formatted_text(pdf, "Número de identificación: ", collaborator.id_card)
        pdf_formatted_text(pdf, "Correo electrónico: ", collaborator.email)
        pdf_formatted_text(pdf, "Número de teléfono: ", collaborator.phone)
        pdf_formatted_text(pdf, "Puesto de trabajo: ", collaborator.job_position)
        pdf.move_down 10
  
        # Date range
        pdf_subtitle(pdf, "Información del reporte")
        pdf_formatted_text(pdf, "Fecha de inicio: ", l(Date.parse(start_date), format: :long).capitalize)
        pdf_formatted_text(pdf, "Fecha de fin: ", l(Date.parse(end_date), format: :long).capitalize)
        pdf_formatted_text(pdf, "Periodo comprendido: ", days_in_words(Date.parse(start_date), Date.parse(end_date)))
        pdf_formatted_text(pdf, "Total de horas registradas: ", "#{total_report_hours.to_s} (#{hours_in_words(total_report_hours)})")
        pdf.move_down 10
        pdf.stroke_horizontal_rule
        pdf.move_down 15
  
        # Detailed report
        if collaborator_report_type == "detailed"
          # Detailed activities table
          pdf_section_heading(
            pdf,
            "Actividades detalladas por proyecto",
            "Esta sección muestra el detalle de las actividades registradas por proyecto, en el periodo de tiempo ingresado."
          )

          activities_grouped_by_project.each do |project_id, activities|
            project = Project.find(project_id)
            table_data = [
              [{ content: "DETALLE DE ACTIVIDADES (#{project.name})", colspan: 3 }],
              ["Fecha", "Fase", "Horas"]
            ]

            activities.each do |activity|
              activity.phases_activities.each do |phase_activity|
                phase = Phase.find(phase_activity.phase_id)
                table_data << [l(activity.date, format: :long).capitalize, "#{phase.code} #{phase.name}", "#{phase_activity.hours.to_s} (#{hours_in_words(phase_activity.hours)})"]
              end
            end

            activities_sum = activities.sum { |activity| activity.phases_activities.sum(&:hours) }
            table_data << [{ content: "Total de horas registradas", colspan: 2}, "#{activities_sum.to_s} (#{hours_in_words(activities_sum)})"]

            pdf_table(table_data, pdf)
            pdf.move_down 20
          end
          
          pdf.move_down 10
        end
        
        # Activities summary table
        pdf_section_heading(
          pdf,
          "Resumen de actividades por fase para cada proyecto",
          "Esta sección muestra el resumen de las actividades registradas por fase para cada uno de los proyectos, en el periodo de tiempo ingresado"
        )

        # Activities by project summary table
        pdf_summary_phases_table(pdf, phases_hours_group_by_project)

        # Footer
        pdf_footer(pdf)
      end
  
      # PDF send
      report_type = collaborator_report_type == "summary" ? "RESUMIDO" : "DETALLADO"
      report_name = "REPORTE-#{report_type}_POR-COLABORADOR_#{(collaborator.fullname).gsub(' ', '-')}_#{start_date}_#{end_date}_#{Time.now.strftime("%H%M")}.pdf"
      send_data pdf.render, filename: report_name, type: 'application/pdf'
    end

    # The `get_grouped_phases` method is responsible for grouping phases by project and calculating the total hours for each phase within a project.
    #
    # Here is a breakdown of the code:
    #
    # 1. Initialize an empty hash to store the grouped phases and their respective hours by project.
    # 2. Iterate over the activities grouped by project.
    # 3. Within each project, iterate over the activities and their associated phases.
    # 4. For each phase, retrieve the phase ID and check if it already exists in the `phases_by_phase` hash.
    #    - If the phase ID exists, increment the repetition count by 1 and add the phase activity hours to the hours sum.
    #    - If the phase ID does not exist, initialize the repetition count with 1 and set the hours sum to the phase activity hours.
    # 5. Store the repetition count and hours sum for each phase in the `phases_by_phase` hash.
    # 6. Add the `phases_by_phase` hash to the `phases_hours_group_by_project` hash, using the project ID as the key.
    # 7. Return the `phases_hours_group_by_project` hash.
    def get_grouped_phases(activities_grouped_by_project)
      phases_hours_group_by_project = {}
      activities_grouped_by_project.each do |project_id, activities|
        phases_by_phase = {}

        activities.each do |activity|
          activity.phases_activities.each do |phase_activity|
            phase_id = phase_activity.phase_id
            repetition_count = phases_by_phase[phase_id]&.first || 0
            hours_sum = phases_by_phase[phase_id]&.last || 0

            repetition_count += 1
            hours_sum += phase_activity.hours

            phases_by_phase[phase_id] = [repetition_count, hours_sum]
          end
        end

        phases_hours_group_by_project[project_id] = phases_by_phase
      end
      phases_hours_group_by_project
    end
  
    # The `general_report` method is responsible for generating the general activities report for active collaborators within a specified date range.
    #
    # Here is a breakdown of the code:
    #
    # 1. Retrieve all active collaborators from the database who have the role "collaborator" and status "active", ordered by fullname in descending order. If there are no active collaborators, redirect to the activities page with an alert message.
    # 2. Retrieve activities within the specified start and end date range, ordered by date in ascending order. If there are no activities in the given range, redirect to the activities page with an alert message.
    # 3. Initialize a new Prawn document for generating the PDF report.
    # 4. Set up the header and footer logos for the PDF.
    # 5. Define the content of the PDF body using a bounding box to control the layout.
    # 6. Add the PDF header, including the title for the general activities report and the information about the date range and active collaborators.
    # 7. Draw horizontal rule and create space between sections.
    # 8. Create a table to display the information of active collaborators, including their fullname, id_card, and job_position.
    # 9. Add a section heading for the active collaborators table and display the table in the PDF.
    # 10. Add a section heading for the activities registered by each collaborator and iterate over each active collaborator.
    # 11. Retrieve activities specific to the current collaborator.
    #     - If no activities are found for the collaborator, display a message indicating the absence of activities for that collaborator in the selected date range.
    #     - If activities are found, group them by project, calculate the total report hours, and group the phases' activities count and sum by project.
    # 12. Add a section heading for the collaborator's activities table and display the summary phases table for each project.
    # 13. Repeat steps 11-14 for each active collaborator.
    # 14. Add the footer to the PDF.
    # 15. Define the report name based on the start date, end date, and current time.
    # 16. Send the PDF report as data to the client with the appropriate filename and type.
    def general_report(start_date, end_date)
      # Active collaborators
      active_collaborators = User.where(role: "collaborator", status: "active").order(fullname: :desc)

      if active_collaborators.nil? || active_collaborators.empty?
        redirect_to activities_path, alert: "No se encontraron colaboradores activos en el sistema."
        #flash[:alert] = "No se encontraron colaboradores activos en el sistema."
        return
      end
  
      # Activities in date range
      activities = Activity.where(date: start_date..end_date).order(date: :asc)
  
      if activities.nil? || activities.empty?
        redirect_to activities_path, alert: "No se encontraron actividades registradas en el periodo de tiempo ingresado."
        return
      end
  
      require 'prawn'
      require 'prawn/table'
  
      pdf = Prawn::Document.new
  
      # Header and footer logos
      pdf_logos(pdf)
  
      # Body
      pdf.bounding_box([pdf.bounds.left, pdf.bounds.top - 50], width: pdf.bounds.width, height: pdf.bounds.height - 120) do
  
        # PDF header
        pdf_document_title(pdf, "REPORTE GENERAL DE ACTIVIDADES POR\nCOLABORADORES ACTIVOS")
  
        # Date range
        pdf_subtitle(pdf, "Información del reporte")
        pdf_formatted_text(pdf, "Fecha de inicio: ", l(Date.parse(start_date), format: :long).capitalize)
        pdf_formatted_text(pdf, "Fecha de fin: ", l(Date.parse(end_date), format: :long).capitalize)
        pdf_formatted_text(pdf, "Periodo comprendido: ", days_in_words(Date.parse(start_date), Date.parse(end_date)))
        pdf_formatted_text(pdf, "Número de colaboradores activos: ", "#{active_collaborators.count}")
        pdf.move_down 10
        pdf.stroke_horizontal_rule
        pdf.move_down 20
  
        # Collaborators table
        table_data = [
          [{ content: "COLABORADORES ACTIVOS", colspan: 3 }],
          ["Nombre completo", "Número de identificación", "Puesto de trabajo"]
        ]
        active_collaborators.each do |collaborator|
          table_data << [collaborator.fullname, collaborator.id_card, collaborator.job_position]
        end
        pdf_section_heading(
          pdf,
          "Colaboradores activos",
          "Esta sección muestra la información de los colaboradores activos en el sistema, al momento de emitir el reporte.",
        )
        pdf_table(table_data, pdf, false)
        pdf.move_down 20
  
        # Collaborators activities tables
        pdf_section_heading(
          pdf,
          "Actividades registradas por colaborador",
          "En esta sección, se presenta un resumen de las actividades registradas por fase en cada proyecto, para cada uno de los colaboradores activos, durante el periodo de tiempo seleccionado."
        )
  
        active_collaborators.each do |collaborator|
          collaborator_activities = activities.where(user_id: collaborator.id)
  
          if collaborator_activities.nil? || collaborator_activities.empty?

            pdf_section_heading(
              pdf,
              collaborator.fullname,
              "#{ collaborator.id_card } / #{ collaborator.job_position}",
              "000000"
            )
            pdf.text "No se encontraron actividades registradas para el/la colaborador/a en el periodo de tiempo ingresado.", size: 11, style: :italic
            pdf.move_down 20
            next
          end
  
          # Activities grouped by project
          activities_grouped_by_project = collaborator_activities.group_by(&:project_id)
          # Total report hours
          total_report_hours = collaborator_activities.sum { |activity| activity.phases_activities.sum(&:hours) }
          # Phases activities grouped count and sum by project
          phases_hours_group_by_project = get_grouped_phases(activities_grouped_by_project)

          pdf_section_heading(
            pdf,
            collaborator.fullname,
            "#{ collaborator.id_card } / #{ collaborator.job_position}\nTotal de horas registradas: #{total_report_hours.to_s} (#{hours_in_words(total_report_hours)})",
            "000000"
          )

          # Activities by project summary table
          pdf_summary_phases_table(pdf, phases_hours_group_by_project)
        end
  
        # Footer
        pdf_footer(pdf)
      end
  
      # PDF send
      report_name = "REPORTE-GENERAL_DE-ACTIVIDADES_#{start_date}_#{end_date}_#{Time.now.strftime("%H%M")}.pdf"
      send_data pdf.render, filename: report_name, type: 'application/pdf'
    end

    # The pdf_logos method is responsible for adding the header and footer logos to the PDF.
    #
    # Here is a breakdown of the code:
    #
    # 1. Require the Prawn gem and the Prawn table gems.
    # 2. Define the paths to the header and footer logos.
    # 3. Define the header and footer for the PDF.
    #   - The header logo is positioned to the top left of the document.
    #   - The footer logo is positioned to the bottom left of the document.
    # 4. Repeat the header and footer on each page of the PDF.
    # 5. Return the PDF.
    def pdf_logos(pdf)
      require 'prawn'
      require 'prawn/table'

      logo_header_path = Rails.root.join('app', 'assets', 'images', 'pdf-header-logo.jpg')
      logo_footer_path = Rails.root.join('app', 'assets', 'images', 'pdf-footer-logo.jpg')

      # Header and footer
      pdf.repeat :all do
        pdf.canvas do
          pdf.bounding_box([25, pdf.bounds.top], width: pdf.bounds.width, height: 100) do
            pdf.image logo_header_path, position: :left, fit: [80, 80]
          end
        end
        pdf.canvas do
          pdf.bounding_box([pdf.bounds.left, pdf.bounds.bottom + 60], width: pdf.bounds.width, height: 100) do
            pdf.image logo_footer_path, position: :left, fit: [pdf.bounds.width - 70, 100]
          end
        end
      end
    end

    # The pdf_table method is responsible for formatting the tables in the PDF.
    # 
    # Here is a breakdown of the code:
    #
    # 1. Require the Prawn gem and the Prawn table gems.
    # 2. Define the table data, header, and width.
    # 3. Define the table styles.
    # 4. Return the PDF table.
    def pdf_table(table_data, pdf, colored_bottom = true)
      require 'prawn'
      require 'prawn/table'

      pdf.table(table_data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = "000000"
        row(0).text_color = "FFFFFF"

        row(1).background_color = "C4C4C4"
        row(1).text_color = "000000"
        row(1).font_style = :bold

        if colored_bottom
          last_row_index = table_data.size - 1
          row(last_row_index).background_color = "85D6C8"
          row(last_row_index).font_style = :bold
          row(last_row_index).text_color = "000000"
        end
      end
    end

    # The `pdf_summary_phases_table` method is responsible for generating a summary table of activities by phases for each project.
    #
    # Here is a breakdown of the code:
    #
    # 1. Iterate over the `phases_hours_group_by_project` data structure, which contains phases grouped by project.
    # 2. Retrieve project details using the `Project.find` method based on the project ID.
    # 3. Initialize the table data array with the headers: "Fase", "Cantidad", and "Total de horas".
    # 4. Initialize variables to track the total number of activities and the total hours for each project.
    # 5. Iterate over the phases and their corresponding data within each project.
    #    - Retrieve phase details using the `Phase.find` method based on the phase ID.
    #    - Extract the repetition count and hours sum from the data.
    #    - Increment the total activities and total hours variables.
    #    - Add a new row to the table data array with the phase name, repetition count, and formatted hours.
    # 6. Add a final row to the table data array with the totals for the project.
    # 7. Render the table using Prawn's `pdf_table` method.
    # 8. Move the cursor down to create spacing between tables.
    def pdf_summary_phases_table(pdf, phases_hours_group_by_project)
      require 'prawn'
      require 'prawn/table'

      # Activities by phases for each project summary table
      phases_hours_group_by_project.each do |project_id, phases_by_phase|
        project = Project.find(project_id)
        table_data = [
          [{ content: "RESUMEN DE ACTIVIDADES (#{project.name})", colspan: 3 }],
          ["Fase", "Cantidad", "Total de horas"]
        ]

        total_activities = 0
        total_hours = 0

        phases_by_phase.each do |phase_id, data|
          phase = Phase.find(phase_id)
          repetition_count = data.first
          hours_sum = data.last
      
          total_activities += repetition_count
          total_hours += hours_sum
      
          table_data << [phase.name, repetition_count, "#{hours_sum.to_s} (#{hours_in_words(hours_sum)})"]
        end

        table_data << ["Total", total_activities, "#{total_hours.to_s} (#{hours_in_words(total_hours)})"]

        pdf_table(table_data, pdf)
        pdf.move_down 20
      end
    end

    # The `pdf_document_title` method is responsible for formatting the document title in the PDF.
    #
    # Here is a breakdown of the code:
    #
    # 1. Require the Prawn gem and the Prawn table gems.
    # 2. Define the document title.
    # 3. Add the document title to the PDF.
    # 4. Add spacing between the document title and the next section.
    # 5. Add a horizontal rule to the PDF.
    # 6. Add spacing between the horizontal rule and the next section.
    # 7. Return the PDF document title.
    def pdf_document_title(pdf, title)
      require 'prawn'
      require 'prawn/table'

      pdf.text title, align: :center, size: 20, style: :bold, color: "44ABA6"
      pdf.move_down 2
      pdf.stroke_horizontal_rule
      pdf.move_down 15
    end

    # The `pdf_subtitle` method is responsible for formatting the subtitles in the PDF.
    #
    # Here is a breakdown of the code:
    #
    # 1. Require the Prawn gem and the Prawn table gems.
    # 2. Define the subtitle.
    # 3. Add the subtitle to the PDF. 
    # 4. Add spacing between the subtitle and the next section.
    # 5. Return the PDF subtitle.
    def pdf_subtitle(pdf, title, color = "44ABA6")
      require 'prawn'
      require 'prawn/table'

      pdf.text title, align: :left, size: 13, style: :bold, color: color
      pdf.move_down 2
    end

    # The `pdf_section_heading` method is responsible for formatting the section headings in the PDF.
    #
    # Here is a breakdown of the code:
    #
    # 1. Require the Prawn gem and the Prawn table gems.
    # 2. Define the section heading title and description.
    # 3. Add the section heading title and description to the PDF.
    # 4. Add spacing between the section heading and the next section.
    # 5. Return the PDF section heading.
    def pdf_section_heading(pdf, title, description, color = "44ABA6")
      require 'prawn'
      require 'prawn/table'

      pdf.text title, align: :left, size: 13, style: :bold, color: color 
      pdf.move_down 2
      pdf.text description, align: :left, size: 11
      pdf.move_down 10
    end

    # The `pdf_formatted_text` method is responsible for formatting the text in the PDF.
    #
    # Here is a breakdown of the code:
    #
    # 1. Require the Prawn gem and the Prawn table gems.
    # 2. Define the bold text and normal text.
    # 3. Add the bold text and normal text to the PDF.
    # 4. Add spacing between the text and the next section.
    # 5. Return the PDF formatted text.
    def pdf_formatted_text(pdf, bold_text, normal_text)
      require 'prawn'
      require 'prawn/table'

      pdf.formatted_text [{ text: bold_text, styles: [:bold] }, { text: normal_text }], size: 11
      pdf.move_down 1
    end

    # The `pdf_footer` method is responsible for formatting the footer in the PDF.
    #
    # Here is a breakdown of the code:
    #
    # 1. Require the Prawn gem and the Prawn table gems.
    # 2. Define the footer text.
    # 3. Add the footer text to the PDF.
    # 4. Add spacing between the footer text and the next section.
    # 5. Return the PDF footer.
    def pdf_footer(pdf)
      require 'prawn'
      require 'prawn/table'

      pdf.formatted_text [
        { text: "Este reporte fue emitido el día: ", styles: [:bold] },
        { text: l(Date.today, format: :long).capitalize, styles: [:normal] },
        { text: ", a las " + Time.now.strftime("%I:%M %p"), styles: [:normal] }
      ], align: :center, size: 10
      pdf.move_down 10

      pdf.text "- Fin del reporte -", align: :center, size: 10, style: :italic, color: "44ABA6"
    end

    # The `days_in_words` method is responsible for formatting the number of days in words.
    #
    # Here is a breakdown of the code:
    #
    # 1. Require the Date gem.
    # 2. Calculate the number of days between the start and end date.
    # 3. Calculate the number of years, months, weeks, and days.
    # 4. Initialize an empty array to store the time units.
    # 5. Add the years, months, weeks, and days to the time units array if they are greater than 0.
    # 6. Join the time units array with a comma and space.
    # 7. Return the time units string.
    def days_in_words(start_date, end_date)
      require 'date'
      days = (end_date - start_date).to_i + 1

      years = days / 365
      days %= 365

      months = days / 30
      days %= 30

      weeks = days / 7
      days %= 7

      time_units = []
      time_units << "#{years} año(s)" if years.positive?
      time_units << "#{months} mes(es)" if months.positive?
      time_units << "#{weeks} semana(s)" if weeks.positive?
      time_units << "#{days} día(s)" if days.positive?

      time_units.join(", ")
    end

    def hours_in_words(hours)
      hours_int = hours.floor
      minutes = ((hours - hours_int) * 60).to_i
    
      hours_text = "#{hours_int} #{hours_int == 1 ? 'hora' : 'horas'}"
      minutes_text = "#{minutes} #{minutes == 1 ? 'minuto' : 'minutos'}"
    
      if hours_int.zero?
        minutes_text
      elsif minutes.zero?
        hours_text
      else
        "#{hours_text} y #{minutes_text}"
      end
    end

    # The valid_date_range method is responsible for validating the start and end date range.
    #
    # Here is a breakdown of the code:
    #
    # 1. Parse the start and end date strings into Date objects.
    # 2. Check if the start and end date are valid.
    # 3. Check if the start date is less than or equal to the end date.
    # 4. Return true if the date range is valid, or false if it is not.
    def valid_date_range(start_date, end_date)
      start_date = Date.parse(start_date) unless start_date.is_a?(Date)
      end_date = Date.parse(end_date) unless end_date.is_a?(Date)
    
      if start_date.nil? || end_date.nil?
        redirect_to activities_path, alert: "Las fechas ingresadas no son válidas."
        #flash[:alert] = "Las fechas ingresadas no son válidas."
        return false
      end
    
      if start_date > end_date
        redirect_to activities_path, alert: "La fecha de inicio debe ser menor o igual a la fecha de fin."
        #flash[:alert] = "La fecha de inicio debe ser menor o igual a la fecha de fin."
        return false
      end

      return true
    end 

    # The set_collaborators method is responsible for retrieving all collaborators from the database.
    # 
    # Here is a breakdown of the code:
    #
    # 1. Retrieve all users with the role "collaborator" from the database and order them by fullname in descending order.
    # 2. Assign the retrieved users to the @collaborators instance variable.
    # 3. Retrieve users with the role "collaborator" and status "active" from the database and order them by fullname in descending order.
    # 4. Assign the retrieved active users to the @active_collaborators instance variable.
    # 5. Return the @collaborators and @active_collaborators instance variables.
    def set_collaborators
      @collaborators = User.where(role: "collaborator").order(fullname: :desc)
      @active_collaborators = User.where(role: "collaborator", status: "active").order(fullname: :desc)
    end

    # The set_phases method is responsible for retrieving all phases from the database.
    def set_phases
      @phases = Phase.all
    end

    # The set_projects method is responsible for retrieving all projects from the database.
    #
    # Here is a breakdown of the code:
    #
    # 1. Retrieve all projects from the database and order them by name in descending order.
    # 2. Assign the retrieved projects to the @projects instance variable.
    # 3. Retrieve all projects that are not in the "finished" stage from the database and order them by name in descending order.
    # 4. Assign the retrieved open projects to the @open_projects instance variable.
    def set_projects 
      @projects = Project.all
      @open_projects = Project.where.not(stage: 8).order(name: :desc)
    end

    # The get_change_log method is responsible for retrieving the change log for the current activity.
    # If there is no change log for the current activity, the @activity_change_log instance variable is set to nil.
    def get_change_log
      @activity_change_log = ChangeLog.where(table_id: @activity.id, table_name: "activity").order(created_at: :desc)
      if @activity_change_log.nil? || @activity_change_log.empty?
        @activity_change_log = nil
      end
    end

    # The create_change_log method is responsible for creating a change log entry for an activity.
    #
    # Here is a breakdown of the code:
    #
    # 1. Generate a timestamp in the format "dd/mm/YYYY - HH:MM" using the current date and time.
    # 2. Retrieve the short name of the current user who is performing the activity.
    # 3. Construct a description for the change log entry using the timestamp and the current user's short name.
    # 4. Create a new instance of the ChangeLog model.
    # 5. Set the attributes of the change log entry, including the table ID of the activity, the user ID of the current user,
    # the constructed description, and the name of the table associated with the activity.
    # 6. Save the change log entry to the database.
    def create_change_log
      description = "[#{Time.now.strftime("%d/%m/%Y - %H:%M")}] #{current_user.get_short_name} registra esta actividad."
      ChangeLog.new(table_id: @activity.id, user_id: current_user.id, description: description, table_name: "activity").save
    end

    # The register_change_log method is responsible for registering changes to an activity.
    #
    # Here is a breakdown of the code:
    #
    # 1. Retrieve the previous changes to the activity.
    # 2. Initialize an empty string to store the description of the changes.
    # 3. Initialize a counter to keep track of the number of changes.
    # 4. Iterate over the previous changes to the activity.
    # 5. For each change, retrieve the attribute name and the old and new values.
    # 6. Construct a description for the change log entry using the attribute name and the old and new values.
    # 7. Add the constructed description to the change log description string.
    # 8. Increment the counter by 1.
    # 9. Create a new instance of the ChangeLog model.
    # 10. Set the attributes of the change log entry, including the table ID of the activity, the user ID of the current user,
    # the constructed description, and the name of the table associated with the activity.
    # 11. Save the change log entry to the database.
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

    # The validate_nested_phases method is responsible for validating the nested phases attributes.
    #
    # Here is a breakdown of the code:
    #
    # 1. Validate if there are nested attributes.
    # 2. Validate if the total hours are greater than or equal to 1 and less than or equal to 24.
    # 3. Validate if all phases are marked to be destroyed.
    # 4. Validate if there are duplicate phases.
    # 5. Return true if the nested phases attributes are valid, or false if they are not.
    def validate_nested_phases
      #validate if there are nested attributes
      if params[:activity][:phases_activities_attributes].nil? || params[:activity][:phases_activities_attributes].empty?
        @activity.errors.add(:phases_activities, "es necesario registrar al menos una fase y sus horas realizadas")
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
        key_word = total_hours < 1 ? "menor a 1" : "mayor a 24"
        @activity.errors.add(:phases_activities, "el total de horas realizadas es #{key_word}")
      end
    end

    # The destroyed_phases_validation method is responsible for validating if all phases are marked to be destroyed.
    #
    # Here is a breakdown of the code:
    #
    # 1. Validate if all phases are marked to be destroyed.
    # 2. If all phases are marked to be destroyed, add an error to the activity.
    # 3. Return true if all phases are marked to be destroyed, or false if they are not.
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

    # The duplicate_phases_validation method is responsible for validating if there are duplicate phases.
    #
    # Here is a breakdown of the code:
    #
    # 1. Validate if there are duplicate phases.
    # 2. If there are duplicate phases, add an error to the activity.
    # 3. Return true if there are duplicate phases, or false if there are not.
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

    # The validate_phases_changes method is responsible for validating changes made to phases and activities in an activity record.
    #
    # Here is a breakdown of the code:
    #
    # 1. If there are any errors on the activity record, the method returns early and does not perform further validation.
    # 2. Retrieve the new attributes for phases and activities from the request parameters.
    # 3. Identify any removed phases by checking for attributes with _destroy set to "1".
    # - If removed phases exist, update the @phase_changes_description variable to include the count and details of the removed activities.
    # - Iterate over the removed phases and retrieve information about each phase, such as its code, name, and hours.
    # - Append the phase details to the @phase_changes_description.
    # - Increment the @count variable and set @phases_changes to true.
    # 4. Identify any new phases that were added.
    # - Create an empty array to store the new phases.
    # - Iterate over the nested attributes of phases and activities.
    # - Skip attributes with _destroy set to "1" or missing phase_id.
    # - Check if the phase is already associated with the activity.
    # - If the phase is not found, add it to the new_phases array.
    # 5. If there are new phases, update the @phase_changes_description variable to include the count and details of the added activities.
    # - Iterate over the new phases and retrieve information about each phase, such as its code, name, and hours.
    # - Append the phase details to the @phase_changes_description.
    # - Increment the @count variable and set @phases_changes to true.
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
