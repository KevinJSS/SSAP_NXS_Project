class ActivitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_activity, only: %i[show edit update destroy], except: :activities_report
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
      return
    end

    validate_date_range(start_date, end_date)

    case report_type
    when "general"
      general_report(start_date, end_date)
    when "collaborator"
      collaborator = User.find_by(id: params[:user_id])
      collaborator_report(collaborator, start_date, end_date)
    when "custom"
      #custom_report(start_date, end_date)
    end

    flash[:notice] = "Reporte generado correctamente."
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

    def general_report(start_date, end_date)
      active_collaborators = User.where(role: "collaborator", status: "active").order(fullname: :desc)
      activities = Activity.where(date: start_date..end_date).order(date: :asc)

      if activities.nil? || activities.empty?
        redirect_to activities_path, alert: "No se encontraron actividades registradas en el rango de fechas especificado."
        return
      end

      require 'prawn'
      require 'prawn/table'

      pdf = Prawn::Document.new

      # Header and footer
      pdf_logos(pdf)

      # Body
      pdf.bounding_box([pdf.bounds.left, pdf.bounds.top - 50], width: pdf.bounds.width, height: pdf.bounds.height - 120) do
        pdf.text "REPORTE GENERAL DE ACTIVIDADES POR \n COLABORADORES ACTIVOS", align: :center, size: 18, style: :bold, color: "44ABA6"
        pdf.move_down 2
        pdf.stroke_horizontal_rule
        pdf.move_down 15

        # report info
        pdf.text "Información del reporte", align: :left, size: 13, style: :bold, color: "44ABA6"
        pdf.move_down 2
        pdf.formatted_text [{ text: "Fecha de inicio: ", styles: [:bold] }, { text: l(Date.parse(start_date), format: :long).capitalize }], size: 11
        pdf.move_down 1
        pdf.formatted_text [{ text: "Fecha de fin: ", styles: [:bold] }, { text: l(Date.parse(end_date), format: :long).capitalize }], size: 11
        pdf.move_down 1
        pdf.formatted_text [{ text: "Periodo comprendido: ", styles: [:bold] }, { text: days_in_words(Date.parse(start_date), Date.parse(end_date)) }], size: 11
        pdf.move_down 1
        pdf.formatted_text [{ text: "Número de colaboradores activos: ", styles: [:bold] }, { text: "#{active_collaborators.count}" }], size: 11
        pdf.move_down 5
        pdf.stroke_horizontal_rule
        pdf.move_down 15
      
        # Collaborators table
        table_data = [
          [{ content: "COLABORADORES ACTIVOS", colspan: 3 }],
          ["Nombre completo", "Número de cédula", "Puesto de trabajo"]
        ]
      
        active_collaborators.each do |collaborator|
          table_data << [collaborator.fullname, collaborator.id_card, collaborator.job_position]
        end

        pdf_section(
          pdf,
          "Colaboradores activos",
          "Esta sección muestra la información de los colaboradores activos en el sistema, al momento de emitir el reporte.",
          table_data
        )

        # Collaborators activities tables
        pdf.text "Actividades registradas por colaborador", size: 13, style: :bold, color: "44ABA6"
        pdf.move_down 2
        pdf.text "Esta sección muestra el resumen de las actividades registradas por fase y por proyecto para cada uno de los colaboradores, en el periodo de tiempo ingresado.", size: 11
        pdf.move_down 10
        
        active_collaborators.each do |collaborator|
          collaborator_activities = collaborator.activities.where(date: start_date..end_date).order(date: :asc)

          if collaborator_activities.nil? || collaborator_activities.empty?
            pdf.text "Actividades registradas por #{collaborator.get_short_name}", size: 13, style: :bold, color: "44ABA6"
            pdf.move_down 2
            pdf.text "No se encontraron actividades registradas para este colaborador en el periodo de tiempo ingresado.", size: 11
            pdf.move_down 10
            next
          end
          
          # Activities by phase 
          phases_activities_grouped_by_phase = PhasesActivity.includes(:phase).where(activity: collaborator_activities).group(:phase_id).sum(:hours)
          collaborator_total_hours = collaborator_activities.sum { |activity| activity.phases_activities.sum(&:hours) }

          table_data = [
            [{ content: "RESUMEN DE ACTIVIDADES POR FASE", colspan: 3 }],
            ["Fase", "Cantidad", "Total de horas"]
          ]

          phases_activities_grouped_by_phase.each do |phase_id, total_hours|
            phase = Phase.find(phase_id)
            phase = phase.code.to_s + " " + phase.name.to_s
            amount = PhasesActivity.includes(:phase).where(activity: collaborator_activities).group(:phase_id).count[phase_id]
            table_data << [phase, amount, "#{total_hours.to_s} (#{hours_in_words(total_hours)})"]
          end

          table_data << [{ content: "Total de horas registradas", colspan: 2}, "#{collaborator_total_hours.to_s} (#{hours_in_words(collaborator_total_hours)})"]

          pdf.text collaborator.fullname, size: 13, style: :bold, color: "000000"
          pdf.move_down 2
          pdf.text "#{ collaborator.id_card } / #{ collaborator.job_position}"
          pdf.move_down 5
          pdf_table(table_data, pdf)
          pdf.move_down 10

          # Activities by project
          activities_grouped_by_project = collaborator_activities.group_by(&:project_id)
          activities_sum_by_project = {}

          activities_grouped_by_project.each do |project_id, activities|
            total_hours = activities.sum { |activity| activity.phases_activities.sum(&:hours) }
            activities_sum_by_project[project_id] = total_hours
          end

          total_report_hours = collaborator_activities.sum { |activity| activity.phases_activities.sum(&:hours) }

          table_data = [
            [{ content: "RESUMEN ACTIVIDADES POR PROYECTO", colspan: 3 }],
            ["Proyecto", "Actividades registradas", "Total de horas"]
          ]
          activities_sum_by_project.each do |project_id, total_hours|
            project = Project.find(project_id)
            table_data << [project.name, activities_grouped_by_project[project_id].count, "#{total_hours.to_s} (#{hours_in_words(total_hours)})"]
          end
          table_data << [{ content: "Total de horas registradas", colspan: 2}, "#{total_report_hours.to_s} (#{hours_in_words(total_report_hours)})"]

          pdf_table(table_data, pdf)
          pdf.move_down 20
        end

        # Footer
        pdf_footer(pdf)
    
        report_name = "REPORTE_POR-COLABORADORES-ACTIVOS_#{start_date}_#{end_date}_#{Time.now.strftime("%H%M")}.pdf"
        send_data pdf.render, filename: report_name, type: 'application/pdf'
      end
    end

    def collaborator_report(collaborator, start_date, end_date)
      collaborator_report_type = params[:collaborator_report_type]

      if collaborator_report_type.nil? || collaborator_report_type.empty?
        redirect_to activities_path, alert: "Es necesario indicar el reporte del colaborador que se desea generar."
        return
      end

      activities = collaborator.activities.where(date: start_date..end_date).order(date: :asc)

      if activities.nil? || activities.empty?
        redirect_to activities_path, alert: "No se encontraron actividades registradas para el colaborador seleccionado en el rango de fechas especificado."
        return
      end

      case collaborator_report_type
        when "summary"
          collaborator_summary_report(activities, collaborator, start_date, end_date)
        when "detailed"
          collaborator_detailed_report(activities, collaborator, start_date, end_date)
      end
    end
    
    def collaborator_detailed_report(activities, collaborator, start_date, end_date)
      total_report_hours = activities.sum { |activity| activity.phases_activities.sum(&:hours) }

      require 'prawn'
      require 'prawn/table'
      pdf = Prawn::Document.new

      # Header and footer
      pdf_logos(pdf)

      # Body
      pdf.bounding_box([pdf.bounds.left, pdf.bounds.top - 50], width: pdf.bounds.width, height: pdf.bounds.height - 120) do
        pdf_header(pdf, "REPORTE DETALLADO DE ACTIVIDADES POR COLABORADOR", collaborator, start_date, end_date, total_report_hours)

        # Activities table
        table_data = [
          [{ content: "ACTIVIDADES REGISTRADAS", colspan: 4 }],
          ["Fecha", "Proyecto", "Fase", "Horas"]
        ]
        activities.each do |activity|
          activity.phases_activities.each do |phase_activity|
            table_data << [l(activity.date, format: :default).capitalize, activity.project.name, phase_activity.phase.code.to_s + " " + phase_activity.phase.name, hours_in_words(phase_activity.hours)]
          end
        end
        table_data << [{ content: "Total de horas registradas", colspan: 3}, hours_in_words(total_report_hours)]

        pdf_section(
          pdf, 
          "Actividades registradas", 
          "Esta sección muestra las actividades registradas por el colaborador, en el periodo de tiempo ingresado.",
          table_data
        )

        # Activities summary table
        table_data = [
          [{ content: "RESUMEN DE ACTIVIDADES POR PROYECTO", colspan: 3 }],
          ["Proyecto", "Actividades registradas", "Total de horas"]
        ]
        activities_grouped_by_project = activities.group_by(&:project_id)
        activities_sum_by_project = {}

        activities_grouped_by_project.each do |project_id, activities|
          total_hours = activities.sum { |activity| activity.phases_activities.sum(&:hours) }
          activities_sum_by_project[project_id] = total_hours
        end

        activities_sum_by_project.each do |project_id, total_hours|
          project = Project.find(project_id)
          table_data << [project.name, activities_grouped_by_project[project_id].count, "#{total_hours.to_s} (#{hours_in_words(total_hours)})"]
        end

        table_data << [{ content: "Total de horas registradas", colspan: 2}, "#{total_report_hours.to_s} (#{hours_in_words(total_report_hours)})"]

        pdf_section(
          pdf,
          "Resumen de actividades por proyecto",
          "Esta sección muestra la cantidad de actividades registradas por proyecto y el total de horas realizadas, en el periodo de tiempo ingresado.",
          table_data
        )

        # Activities by phase summary table
        table_data = [
          [{ content: "RESUMEN DE ACTIVIDADES POR FASE", colspan: 3 }],
          ["Fase", "Cantidad", "Total de horas"]
        ]

        phases_activities_grouped_by_phase = PhasesActivity.includes(:phase).where(activity: activities).group(:phase_id).sum(:hours)
        phases_activities_grouped_by_phase.each do |phase_id, total_hours|
          phase = Phase.find(phase_id)
          phase = phase.code.to_s + " " + phase.name.to_s
          amount = PhasesActivity.includes(:phase).where(activity: activities).group(:phase_id).count[phase_id]
          table_data << [phase, amount, "#{total_hours.to_s} (#{hours_in_words(total_hours)})"]
        end

        table_data << [{ content: "Total de horas registradas", colspan: 2}, "#{total_report_hours.to_s} (#{hours_in_words(total_report_hours)})"]

        pdf_section(
          pdf,
          "Resumen de actividades por fase",
          "Esta sección muestra las actividades registradas por fase, la cantidad de veces que trabajó sobre cada una de ellas y el total de horas realizadas, en el periodo de tiempo ingresado.",
          table_data
        )
        pdf.move_down 10

        # Footer
        pdf_footer(pdf)
      end

        # PDF send
        report_name = "REPORTE-DETALLADO_POR-COLABORADOR_#{(collaborator.fullname).gsub(' ', '-')}_#{start_date}_#{end_date}_#{Time.now.strftime("%H%M")}.pdf"
        send_data pdf.render, filename: report_name, type: 'application/pdf'
    end

    def collaborator_summary_report(activities, collaborator, start_date, end_date)
      activities_grouped_by_project = activities.group_by(&:project_id)
      activities_sum_by_project = {}

      activities_grouped_by_project.each do |project_id, activities|
        total_hours = activities.sum { |activity| activity.phases_activities.sum(&:hours) }
        activities_sum_by_project[project_id] = total_hours
      end

      phases_activities_grouped_by_phase = PhasesActivity.includes(:phase).where(activity: activities).group(:phase_id).sum(:hours)
      total_report_hours = activities.sum { |activity| activity.phases_activities.sum(&:hours) }

      require 'prawn'
      require 'prawn/table'
      pdf = Prawn::Document.new
      
      # Header and footer
      pdf_logos(pdf)

      # Body
      pdf.bounding_box([pdf.bounds.left, pdf.bounds.top - 50], width: pdf.bounds.width, height: pdf.bounds.height - 120) do
        pdf_header(pdf, "REPORTE DE ACTIVIDADES POR COLABORADOR", collaborator, start_date, end_date, total_report_hours)

        # By project table
        table_data = [
          [{ content: "RESUMEN ACTIVIDADES POR PROYECTO", colspan: 3 }],
          ["Proyecto", "Actividades registradas", "Total de horas"]
        ]
        activities_sum_by_project.each do |project_id, total_hours|
          project = Project.find(project_id)
          table_data << [project.name, activities_grouped_by_project[project_id].count, "#{total_hours.to_s} (#{hours_in_words(total_hours)})"]
        end
        table_data << [{ content: "Total de horas registradas", colspan: 2}, "#{total_report_hours.to_s} (#{hours_in_words(total_report_hours)})"]

        pdf_section(
          pdf, 
          "Resumen de actividades por proyecto", 
          "Esta sección muestra la cantidad de actividades registradas por proyecto y el total de horas realizadas, en el periodo de tiempo ingresado.",
          table_data
        )

        # By phase table
        table_data = [
          [{ content: "RESUMEN DE ACTIVIDADES POR FASE", colspan: 3 }],
          ["Fase", "Cantidad", "Total de horas"]
        ]
        phases_activities_grouped_by_phase.each do |phase_id, total_hours|
          phase = Phase.find(phase_id)
          phase = phase.code.to_s + " " + phase.name.to_s
          amount = PhasesActivity.includes(:phase).where(activity: activities).group(:phase_id).count[phase_id]
          table_data << [phase, amount, "#{total_hours.to_s} (#{hours_in_words(total_hours)})"]
        end
        table_data << [{ content: "Total de horas registradas", colspan: 2}, "#{total_report_hours.to_s} (#{hours_in_words(total_report_hours)})"]

        pdf_section(
          pdf,
          "Resumen de actividades por fase",
          "Esta sección muestra las actividades registradas por fase, la cantidad de veces que trabajó sobre cada una de ellas y el total de horas realizadas, en el periodo de tiempo ingresado.",
          table_data
        )
        pdf.move_down 10

        # Footer
        pdf_footer(pdf)

        # PDF send
        report_name = "REPORTE-RESUMIDO_POR-COLABORADOR_#{(collaborator.fullname).gsub(' ', '-')}_#{start_date}_#{end_date}_#{Time.now.strftime("%H%M")}.pdf"
        send_data pdf.render, filename: report_name, type: 'application/pdf'
      end
    end

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

    def pdf_table(table_data, pdf)
      require 'prawn'
      require 'prawn/table'

      pdf.table(table_data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = "000000"
        row(0).text_color = "FFFFFF"

        row(1).background_color = "C4C4C4"
        row(1).text_color = "000000"
        row(1).font_style = :bold
      end
    end

    def pdf_header(pdf, report_name, collaborator, start_date, end_date, total_report_hours)
      require 'prawn'
      require 'prawn/table'

      # Title
      pdf.text report_name, align: :center, size: 20, style: :bold, color: "44ABA6"
      pdf.move_down 2
      pdf.stroke_horizontal_rule
      pdf.move_down 15

      # Collaborator info
      pdf.text "Información del colaborador", align: :left, size: 13, style: :bold, color: "44ABA6"
      pdf.move_down 2
      pdf.move_down 1
      pdf.formatted_text [{ text: "Nombre completo: ", styles: [:bold] }, { text: collaborator.fullname }], size: 11
      pdf.move_down 1
      pdf.formatted_text [{ text: "Número de cédula: ", styles: [:bold] }, { text: collaborator.id_card }], size: 11
      pdf.move_down 1
      pdf.formatted_text [{ text: "Correo electrónico: ", styles: [:bold] }, { text: collaborator.email }], size: 11
      pdf.move_down 1
      pdf.formatted_text [{ text: "Número de teléfono: ", styles: [:bold] }, { text: collaborator.phone }], size: 11
      pdf.move_down 1
      pdf.formatted_text [{ text: "Puesto de trabajo: ", styles: [:bold] }, { text: collaborator.job_position }], size: 11
      pdf.move_down 10

      # Date range
      pdf.text "Información del reporte", align: :left, size: 13, style: :bold, color: "44ABA6"
      pdf.move_down 2
      pdf.formatted_text [{ text: "Fecha de inicio: ", styles: [:bold] }, { text: l(Date.parse(start_date), format: :long).capitalize }], size: 11
      pdf.move_down 1
      pdf.formatted_text [{ text: "Fecha de fin: ", styles: [:bold] }, { text: l(Date.parse(end_date), format: :long).capitalize }], size: 11
      pdf.move_down 1
      pdf.formatted_text [{ text: "Periodo comprendido: ", styles: [:bold] }, { text: days_in_words(Date.parse(start_date), Date.parse(end_date)) }], size: 11
      pdf.move_down 1
      pdf.formatted_text [{ text: "Total de horas registradas: ", styles: [:bold] }, { text: "#{total_report_hours.to_s} (#{hours_in_words(total_report_hours)})" }], size: 11

      pdf.move_down 10
      pdf.stroke_horizontal_rule
      pdf.move_down 15
    end

    def pdf_section (pdf, title, description, table_data)
      require 'prawn'
      require 'prawn/table'

      pdf.text title, align: :left, size: 13, style: :bold, color: "44ABA6"
      pdf.move_down 2
      pdf.text description, align: :left, size: 11
      pdf.move_down 10

      pdf_table(table_data, pdf)
      pdf.move_down 20
    end

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

    def validate_date_range(start_date, end_date)
      start_date = Date.parse(start_date) unless start_date.is_a?(Date)
      end_date = Date.parse(end_date) unless end_date.is_a?(Date)
    
      if start_date.nil? || end_date.nil?
        redirect_to activities_path, alert: "Las fechas ingresadas no son válidas."
        return
      end
    
      if start_date > end_date
        redirect_to activities_path, alert: "La fecha de inicio debe ser menor o igual a la fecha de fin."
        return
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
      @activity_change_log = ChangeLog.where(table_id: @activity.id, table_name: "activity").order(created_at: :desc)
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
