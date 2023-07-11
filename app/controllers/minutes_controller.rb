class MinutesController < ApplicationController
  include ActionView::Helpers::SanitizeHelper

  before_action :authenticate_user!
  before_action :set_minute, only: %i[ show edit update destroy pdf ]
  before_action :set_attendees, :set_projects
  before_action :get_change_log, only: %i[ show edit update ]

  # GET /minutes or /minutes.json
  def index
    @q = Minute.ransack(params[:q])
    @minutes = @q.result(distinct: true).order(updated_at: :desc).paginate(page: params[:page], per_page: 3)
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

  def pdf
    require 'prawn'
    require 'prawn/table'

    pdf = Prawn::Document.new
    logo_header_path = Rails.root.join('app', 'assets', 'images', 'pdf-header-logo.jpg')
    logo_footer_path = Rails.root.join('app', 'assets', 'images', 'pdf-footer-logo.jpg')
    name = "MINUTA_#{(@minute.project.name).gsub!(' ', '-')}_#{Time.now.strftime("%d-%m-%Y")}_#{@minute[:id]}"

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

    # Body
    pdf.bounding_box([pdf.bounds.left, pdf.bounds.top - 50], width: pdf.bounds.width, height: pdf.bounds.height - 120) do
      
      # Title
      pdf.text "MINUTA DE REUNIÓN", align: :center, size: 18, style: :bold, color: "44ABA6"
      pdf.move_down 5

      # Meeting information
      data = [
        #['Identificador: ', name],
        ['Proyecto: ', Project.find_by(id: @minute.project_id).name],
        ['Título de la reunión: ', @minute.meeting_title],
        ['Fecha de la reunión: ', l(@minute.meeting_date, format: :long)],
        ['Hora: ', @minute.start_time.strftime("%I:%M %p") + " - " + @minute.end_time.strftime("%I:%M %p")],
      ]
      
      data.each do |label, value|
        pdf.formatted_text [
          { text: label, styles: [:bold] },
          { text: value, styles: [:normal] }
        ], size: 13, align: :center
      
        pdf.move_down 2
      end
      pdf.move_down 20

      # Meeting objectives
      objectives = @minute.meeting_objectives.body.to_plain_text.gsub(/^\d+\.\s/, '').split("\n").map(&:strip).reject(&:blank?)
      
      if objectives.any?
        table_data = [
          [{ content: "OBJETIVOS DE LA REUNIÓN", colspan: 2 }],
          [{ content: "#", align: :center }, "Objetivo"]
        ]
  
        objectives.each_with_index do |objective, index|
          table_data << [{ content: "#{index + 1}", width: 50, align: :center }, { content: objective }]
        end
  
        pdf.move_down 10
  
        pdf.table(table_data, width: pdf.bounds.width, cell_style: { size: 13, border_width: 0.5, border_color: "000000", inline_format: true }, column_widths: [50, pdf.bounds.width - 50]) do
          cells.borders = [:top, :bottom, :left, :right]
          row(0).background_color = "000000"
          row(0).text_color = "FFFFFF"
          row(0).font_style = :bold
  
          row(1).background_color = "C4C4C4"
          row(1).text_color = "000000"
          row(1).font_style = :bold
        end
        pdf.move_down 20
      end

      # Assitants
      table_data = [
        [{ content: "LISTA DE ASISTENTES", colspan: 3 }],
        [{ content: "#", align: :center }, "Nombre", "Puesto de trabajo"]
      ]

      @minute.minutes_users.each_with_index do |user, index|
        table_data << [{ content: "#{index + 1}", width: 50, align: :center }, { content: user.user.fullname }, { content: user.user.job_position }]
      end

      pdf.table(table_data, width: pdf.bounds.width, cell_style: { size: 13, border_width: 0.5, border_color: "000000", inline_format: true }) do
        cells.borders = [:top, :bottom, :left, :right]
        row(0).background_color = "000000"
        row(0).text_color = "FFFFFF"
        row(0).font_style = :bold

        row(1).background_color = "C4C4C4"
        row(1).text_color = "000000"
        row(1).font_style = :bold
      end
      pdf.move_down 20

      # Discussed topics
      discussed_topics = @minute.discussed_topics.body.to_plain_text.gsub(/^\d+\.\s/, '').split("\n").map(&:strip).reject(&:blank?)
      
      if discussed_topics.any?
        table_data = [
          [{ content: "TEMAS DISCUTIDOS", colspan: 2 }],
          [{ content: "#", align: :center }, "Tema discutido"]
        ]
        
        discussed_topics.each_with_index do |topic, index|
          table_data << [{ content: "#{index + 1}", width: 50, align: :center }, { content: topic }]
        end
  
        pdf.table(table_data, width: pdf.bounds.width, cell_style: { size: 13, border_width: 0.5, border_color: "000000", inline_format: true }, column_widths: [50, pdf.bounds.width - 50]) do
          cells.borders = [:top, :bottom, :left, :right]
          row(0).background_color = "000000"
          row(0).text_color = "FFFFFF"
          row(0).font_style = :bold
  
          row(1).background_color = "C4C4C4"
          row(1).text_color = "000000"
          row(1).font_style = :bold
        end
        pdf.move_down 20
      end

      # Pending topics
      pending_topics = @minute.pending_topics.body.to_plain_text.gsub(/^\d+\.\s/, '').split("\n").map(&:strip).reject(&:blank?)

      if pending_topics.any?
        table_data = [
          [{ content: "TEMAS PENDIENTES", colspan: 2 }],
          [{ content: "#", align: :center }, "Tema pendiente"]
        ]
  
        pending_topics.each_with_index do |topic, index|
          table_data << [{ content: "#{index + 1}", width: 50, align: :center }, { content: topic }]
        end
  
        pdf.table(table_data, width: pdf.bounds.width, cell_style: { size: 13, border_width: 0.5, border_color: "000000", inline_format: true }, column_widths: [50, pdf.bounds.width - 50]) do
          cells.borders = [:top, :bottom, :left, :right]
          row(0).background_color = "000000"
          row(0).text_color = "FFFFFF"
          row(0).font_style = :bold
  
          row(1).background_color = "C4C4C4"
          row(1).text_color = "000000"
          row(1).font_style = :bold
        end
        pdf.move_down 20
      end

      # Agreements
      agreements = @minute.agreements.body.to_plain_text.gsub(/^\d+\.\s/, '').split("\n").map(&:strip).reject(&:blank?)

      if agreements.any?
        table_data = [
          [{ content: "ACUERDOS", colspan: 2 }],
          [{ content: "#", align: :center }, "Acuerdo"]
        ]
  
        agreements.each_with_index do |agreement, index|
          table_data << [{ content: "#{index + 1}", width: 50, align: :center }, { content: agreement }]
        end
  
        pdf.table(table_data, width: pdf.bounds.width, cell_style: { size: 13, border_width: 0.5, border_color: "000000", inline_format: true }, column_widths: [50, pdf.bounds.width - 50]) do
          cells.borders = [:top, :bottom, :left, :right]
          row(0).background_color = "000000"
          row(0).text_color = "FFFFFF"
          row(0).font_style = :bold
  
          row(1).background_color = "C4C4C4"
          row(1).text_color = "000000"
          row(1).font_style = :bold
        end
        pdf.move_down 20
      end

      # Meeting notes
      meeting_notes = @minute.meeting_notes.body.to_plain_text.gsub(/^\d+\.\s/, '').split("\n").map(&:strip).reject(&:blank?)
      
      if meeting_notes.any?
        table_data = [
          [{ content: "ANOTACIONES DE LA REUNIÓN", colspan: 2 }],
          [{ content: "#", align: :center }, "Anotación"]
        ]
  
        meeting_notes.each_with_index do |note, index|
          table_data << [{ content: "#{index + 1}", width: 50, align: :center }, { content: note }]
        end
  
        pdf.table(table_data, width: pdf.bounds.width, cell_style: { size: 13, border_width: 0.5, border_color: "000000", inline_format: true }, column_widths: [50, pdf.bounds.width - 50]) do
          cells.borders = [:top, :bottom, :left, :right]
          row(0).background_color = "000000"
          row(0).text_color = "FFFFFF"
          row(0).font_style = :bold
  
          row(1).background_color = "C4C4C4"
          row(1).text_color = "000000"
          row(1).font_style = :bold
        end
        pdf.move_down 20
      end

      # Minute data
      pdf.formatted_text [
        { text: "Identificador: ", styles: [:bold] },
        { text: name, styles: [:normal] }
      ], align: :center, size: 10

      pdf.move_down 5

      pdf.formatted_text [
        { text: "Fecha de creación: ", styles: [:bold] },
        { text: l(Date.today, format: :long), styles: [:normal] },
        { text: ", " + Time.now.strftime("%I:%M %p"), styles: [:normal] }
      ], align: :center, size: 10
    end

    name = name + ".pdf"
    send_data(pdf.render, filename: name, type: 'application/pdf')
  end

  # POST /minutes or /minutes.json
  def create
    @minute = Minute.new(minute_params)

    validate_attendees

    respond_to do |format|
      if !@minute.errors.any? && @minute.save
        #Create change log
        create_change_log

        format.html { redirect_to minute_url(@minute), notice: "Minuta agregada correctamente." }
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

        #register change log
        register_change_log

        format.html { redirect_to minute_url(@minute), notice: "Minuta actualizada correctamente." }
        format.json { render :show, status: :ok, location: @minute }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @minute.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /minutes/1 or /minutes/1.json
  def destroy
    respond_to do |format|
      format.html { redirect_to minute_url(@minute), alert: "No es permitido eliminar este registro." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_minute
      @minute = Minute.find(params[:id]) rescue nil

      if @minute.nil?
        redirect_to minutes_path, alert: "La minuta a la que intenta acceder no existe."
      end
    end

    def set_projects 
      @projects = Project.all
      @open_projects = Project.where.not(stage: 8).order(name: :desc)
    end

    def set_attendees
      @attendees = User.all
      @active_attendees = User.where(status: "active").order(fullname: :desc)
    end

    def get_change_log
      @minutes_change_log = ChangeLog.where(table_name: 'minute', table_id: @minute.id).order(created_at: :desc)
      if @minutes_change_log.empty? || @minutes_change_log.nil?
        @minutes_change_log = nil
      end
    end

    def create_change_log
      description = "[#{Time.now.strftime("%d/%m/%Y - %H:%M")}] #{current_user.get_short_name} crea esta minuta."
      ChangeLog.new(table_id: @minute.id, user_id: current_user.id, description: description, table_name: "minute").save
    end

    def register_change_log
      @description = ""
      @count = 1
    
      process_attribute_changes
      process_action_text_changes
    
      validate_attendees_changes
    
      return if @description.empty?
    
      @description = "[#{Time.now.strftime("%d/%m/%Y - %H:%M")}] #{current_user.get_short_name} realizó los siguientes cambios: #{@description}"
      ChangeLog.create(table_id: @minute.id, user_id: current_user.id, description: @description, table_name: "minute")
      @description = ""
    end
    
    def process_attribute_changes
      attribute_mappings = {
        "meeting_title" => "el título de la reunión",
        "meeting_date" => "la fecha de la reunión",
        "start_time" => "la hora de inicio de la reunión",
        "end_time" => "la hora de finalización de la reunión",
        "project_id" => "el proyecto"
      }
    
      @minute.previous_changes.each do |attribute, values|
        old_value, new_value = values
        attribute_name = attribute_mappings[attribute]

        next if attribute_name.nil? || old_value == new_value
    
        if attribute == "start_time" || attribute == "end_time"
          old_value = old_value.strftime("%I:%M %p")
          new_value = new_value.strftime("%I:%M %p")
          next if old_value == new_value

        elsif attribute == "project_id"
          old_value = Project.find(old_value).name
          new_value = Project.find(new_value).name
        end
    
        @description += "(#{@count}) Cambió #{attribute_name} de '#{old_value}' a '#{new_value}'. "
        @count += 1
      end
    end
    
    def process_action_text_changes
      action_text_attributes = {
        'meeting_objectives' => 'los objetivos de la reunión',
        'discussed_topics' => 'los temas discutidos',
        'pending_topics' => 'los temas pendientes',
        'meeting_notes' => 'las notas de la reunión'
      }
    
      action_text_attributes.each do |attribute, attribute_name|
        changes = @minute.send(attribute).previous_changes
        previous_content = changes['body'][0].to_plain_text if changes.present?
        current_content = @minute.send(attribute).body.to_plain_text
    
        next if previous_content.blank?
    
        previous_items = previous_content.split("\n").map(&:strip).reject(&:blank?)
        current_items = current_content.split("\n").map(&:strip).reject(&:blank?)
    
        added_items = current_items - previous_items
        removed_items = previous_items - current_items
    
        if added_items.any?
          added_items_str = added_items.map { |item| "'#{item}'" }.join(", ")
          @description += "(#{@count}) Agregó el siguiente contenido a #{attribute_name}: #{added_items_str}. \n"
          @count += 1
        end
    
        if removed_items.any?
          removed_items_str = removed_items.map { |item| "'#{item}'" }.join(", ")
          @description += "(#{@count}) Eliminó el siguiente contenido de #{attribute_name}: #{removed_items_str}. \n"
          @count += 1
        end
      end
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
          destroy_value = attributes["_destroy"]
          deletedAssociations += 1 if destroy_value != "false"
        end

        if @minute.minutes_users.count == deletedAssociations
          @minute.errors.add(:minutes_users, "es necesario seleccionar al menos un asistente")
          false
        end
      end
    end

    def duplicate_attendees_validation
      nested_attributes = params[:minute][:minutes_users_attributes]
      return unless !nested_attributes.nil?
      
      user_ids = []
      nested_attributes.each do |index, attributes|
        user_ids << attributes["user_id"] if attributes["_destroy"] == "false"
      end

      duplicates = user_ids.select { |id| user_ids.count(id) > 1 }.uniq
      if !duplicates.empty?
        @minute.errors.add(:minutes_users, "no puede haber asistentes duplicados")
      end
    end

    def validate_attendees_changes
      return if @minute.errors.any?
      new_attributes = params.fetch(:minute, {}).fetch(:minutes_users_attributes, {}).values

      added_users = new_attributes.reject { |new_user| @minute.minutes_users.any? { |existing_user| existing_user.id.to_s == new_user[:id] || new_user[:_destroy] != "false" } }
      removed_users = new_attributes.reject { |user| user[:_destroy] == "false" }

      if !removed_users.empty?
        @description = @description + " (#{@count}) Eliminó los/las siguientes asistentes: "

        removed_users.each do |user|
          @description = @description + "#{User.find(user[:user_id]).get_short_name}, "
        end

        @description = @description.chomp(", ")
        @count += 1
      end

      if !added_users.empty?
        @description = @description + " (#{@count}) Agregó los/las siguientes asistentes: "

        added_users.each do |user|
          @description = @description + "#{User.find(user[:user_id]).get_short_name}, "
        end

        @description = @description.chomp(", ")
        @count += 1
      end
    end

    # Only allow a list of trusted parameters through.
    def minute_params
      params.require(:minute).permit(:meeting_title, :meeting_date, :start_time, :end_time, :meeting_objectives, :discussed_topics, :pending_topics, :agreements, :meeting_notes, :project_id, minutes_users_attributes: [:id, :user_id, :_destroy])
    end
end
