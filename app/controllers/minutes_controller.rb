class MinutesController < ApplicationController
  include ActionView::Helpers::SanitizeHelper

  # The `before_action` callback method ensures that the user is authenticated
  # before accessing any action in this controller. It helps enforce the requirement
  # for a user to be logged in before interacting with the `MinutesController`.
  before_action :authenticate_user!

  # The `before_action` callback method 'set_minute' is used to set the minute
  # instance variable before calling the `show`, `edit`, `update`, and `destroy`
  # methods to ensure that the minute exists in the database.
  before_action :set_minute, only: %i[ show edit update destroy pdf ]

  # The `before_action` callback method 'set_attendees' and 'set_projects' is used to set the attendees and projects
  # instance variables before calling the `new` and `edit` methods to ensure that
  # the attendees exist in the database.
  before_action :set_attendees, :set_projects

  # The `before_action` callback method 'get_change_log' is used to set the change log
  # instance variable before calling the `show`, `edit`, `update`, and `destroy`
  # methods to ensure that the change log exists in the database.
  before_action :get_change_log, only: %i[ show edit update ]

  # GET /minutes or /minutes.json

  # The `index` method is used to retrieve all the minutes from the database
  # and display them in a paginated manner. The `index` method also allows
  # the user to search for minutes by their allowed attributes.
  def index
    @q = Minute.ransack(params[:q])
    @minutes = @q.result(distinct: true).order(updated_at: :desc).paginate(page: params[:page], per_page: 3)
  end

  # GET /minutes/1 or /minutes/1.json

  # The `show` method is used to retrieve a single minute from the database
  # and display it to the user.
  def show
    redirect_to edit_minute_path(@minute)
  end

  # GET /minutes/new

  # The `new` method is used to create a new minute instance variable
  # and display it to the user.
  def new
    @minute = Minute.new
  end

  # GET /minutes/1/edit

  # The `edit` method is used to retrieve a single minute from the database
  # and display it to the user.
  def edit
  end

  # The `pdf` method is used to generate a pdf file from the minute
  #
  # Breaking down the `pdf` method:
  #
  # 1. The `require` method is used to load the `prawn` and `prawn/table` gems.
  # 2. The `pdf` variable is used to create a new `Prawn::Document` instance.
  # 3. The `name` variable is used to store the name of the pdf file.
  # 4. The `create_pdf` method is used to create the pdf file.
  # 5. The `name` variable is used to store the name of the pdf file.
  # 6. The `send_data` method is used to send the pdf file to the user.
  def pdf
    require 'prawn'
    require 'prawn/table'

    pdf = Prawn::Document.new    
    name = "MINUTA_#{(@minute.project.name).gsub!(' ', '-')}_#{Time.now.strftime("%d-%m-%Y_%H%M")}_#{@minute[:id]}"

    create_pdf(pdf)

    name = name + ".pdf"
    send_data(pdf.render, filename: name, type: 'application/pdf')
  end

  # The `send_email` method is used to generate a pdf file from the minute
  #
  # Breaking down the `send_email` method:
  #
  # 1. The `require` method is used to load the `prawn` and `prawn/table` gems.
  # 2. The `pdf` variable is used to create a new `Prawn::Document` instance.
  # 3. The `name` variable is used to store the name of the pdf file.
  # 4. The `create_pdf` method is used to create the pdf file.
  # 5. The `name` variable is used to store the name of the pdf file.
  # 6. The `send_data` method is used to send the pdf file to the user.
  # 7. The `attendees` variable is used to store the attendees of the minute.
  # 8. It iterates through the attendees and sends the email to each attendee.
  def send_email
    require 'prawn'
    require 'prawn/table'

    @minute = Minute.find(params[:id])

    pdf = Prawn::Document.new
    name = "MINUTA_#{(@minute.project.name).gsub!(' ', '-')}_#{Time.now.strftime("%d-%m-%Y_%H%M")}_#{@minute.id}"

    create_pdf(pdf)

    name = name + ".pdf"
    pdf_file_path = Rails.root.join('tmp', name)
    pdf.render_file(pdf_file_path)

    #send email
    attendees = @minute.minutes_users.map(&:user).uniq
    
    attendees.each do |attendee|
      MinutesMailer.send_minutes(attendee, attendee.email.to_s, @minute, pdf_file_path.to_s).deliver_later
    end

    respond_to do |format|
      format.html { redirect_to minute_url(@minute), notice: "Minuta enviada correctamente." }
      format.json { render :show, status: :ok, location: @minute }
    end
  end

  # POST /minutes or /minutes.json

  # The `create` method is used to create a new minute instance variable
  # 
  # Breaking down the `create` method:
  #
  # 1. The `@minute` variable is used to create a new minute instance variable
  #    with the parameters passed in the `minute_params` method.
  # 2. The `validate_attendees` method is used to validate the attendees of the minute.
  # 3. The `respond_to` method is used to redirect the user to the minute page
  #    and display a success message if the minute is successfully created.
  # 4. The `respond_to` method is used to render the `new` template and display
  #    an error message if the minute is not successfully created.
  # 5. Finally, it will create a change log for the minute.
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

  # The `update` method is used to update a single minute instance variable
  #
  # Breaking down the `update` method:
  #
  # 1. The `@minute` variable is used to retrieve a single minute from the database
  #    and update it with the parameters passed in the `minute_params` method.
  # 2. The `validate_attendees` method is used to validate the attendees of the minute.
  # 3. The `respond_to` method is used to redirect the user to the minute page
  #    and display a success message if the minute is successfully updated.
  # 4. The `respond_to` method is used to render the `edit` template and display
  #    an error message if the minute is not successfully updated.
  # 5. Finally, it will register a change log for the minute.
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
  
  # The `destroy` method is used to delete a single minute instance variable
  # In this case, the `destroy` method is not allowed to delete a minute
  # it will only redirect the user to the minute page and display an alert notification.
  def destroy
    respond_to do |format|
      format.html { redirect_to minute_url(@minute), alert: "No es permitido eliminar este registro." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.

    # The `set_minute` method is used to set the minute instance variable
    # before calling the `show`, `edit`, `update`, and `destroy` methods
    # to ensure that the minute exists in the database.
    def set_minute
      @minute = Minute.find(params[:id]) rescue nil

      if @minute.nil?
        redirect_to minutes_path, alert: "La minuta a la que intenta acceder no existe."
      end
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

    # The set_attendees method is responsible for retrieving all attendees from the database.
    #
    # Here is a breakdown of the code:
    #
    # 1. Retrieve all attendees from the database and order them by fullname in descending order.
    # 2. Assign the retrieved attendees to the @attendees instance variable.
    # 3. Retrieve all attendees that are in the "active" status from the database and order them by fullname in descending order.
    # 4. Assign the retrieved active attendees to the @active_attendees instance variable.
    def set_attendees
      @attendees = User.all
      @active_attendees = User.where(status: "active").order(fullname: :desc)
    end

    # The `create_pdf` method is used to create a pdf file from the minute
    #
    # Breaking down the `create_pdf` method:
    #
    # 1. The `logo_header_path` variable is used to store the path of the header logo.
    # 2. The `logo_footer_path` variable is used to store the path of the footer logo.
    # 3. The `pdf.repeat` method is used to repeat the header and footer on each page.
    # 4. The `pdf.canvas` method is used to create a canvas for the header and footer.
    # 5. The `pdf.bounding_box` method is used to create a bounding box for the header, footer and body content.
    # 7. Then it will add minute pdf content needed for the pdf file.
    # 8. Finally, it will add the minute data to the pdf file and return the pdf file.
    def create_pdf(pdf)
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
          { text: "Esta minuta fue emitida el día: ", styles: [:bold] },
          { text: l(Date.today, format: :long).capitalize, styles: [:normal] },
          { text: ", a las " + Time.now.strftime("%I:%M %p"), styles: [:normal] }
        ], align: :center, size: 10
        pdf.move_down 10

        pdf.text "- Fin de la minuta -", align: :center, size: 10, style: :italic, color: "44ABA6"
      end
    end

    # The `get_change_log` method is used to set the change log instance variable
    # before calling the `show`, `edit`, `update`, and `destroy` methods
    # to ensure that the change log exists in the database.
    def get_change_log
      @minutes_change_log = ChangeLog.where(table_name: 'minute', table_id: @minute.id).order(created_at: :desc)
      if @minutes_change_log.empty? || @minutes_change_log.nil?
        @minutes_change_log = nil
      end
    end

    # The `create_change_log` method is used to create a change log for the minute
    # 
    # Breaking down the `create_change_log` method:
    #
    # 1. The `description` variable is used to store the description of the change log.
    # 2. The `ChangeLog` model is used to create a new change log instance variable
    #    with the parameters passed in the `create_change_log` method.
    # 3. The `save` method is used to save the change log instance variable to the database.
    def create_change_log
      description = "[#{Time.now.strftime("%d/%m/%Y - %H:%M")}] #{current_user.get_short_name} crea esta minuta."
      ChangeLog.new(table_id: @minute.id, user_id: current_user.id, description: description, table_name: "minute").save
    end

    # The `register_change_log` method is used to register a change log for the minute
    # 
    # Breaking down the `register_change_log` method:
    #
    # 1. The `description` variable is used to store the description of the change log.
    # 2. The `count` variable is used to store the number of changes made to the minute.
    # 3. The `process_attribute_changes` method is used to process the attribute changes.
    # 4. The `process_action_text_changes` method is used to process the action text changes.
    # 5. The `validate_attendees_changes` method is used to validate the attendees changes.
    # 6. The `ChangeLog` model is used to create a new change log instance variable
    #    with the parameters passed in the `create_change_log` method.
    # 7. The `save` method is used to save the change log instance variable to the database.
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
    
    # The `process_attribute_changes` method is used to process the attribute changes.
    #
    # Breaking down the `process_attribute_changes` method:
    #
    # 1. The `attribute_mappings` variable is used to store the attribute mappings.
    # 2. The `@minute` variable is used to retrieve a single minute from the database.
    # 3. The `previous_changes` method is used to retrieve the previous changes of the minute.
    # 4. The `strftime` method is used to format the time.
    # 5. The `each` method is used to iterate through the previous changes.
    # 6. The `attribute_name` variable is used to store the attribute name.
    # 7. Then it will check if the attribute name is nil or if the old value is equal to the new value.
    # 8. If the attribute name is nil or if the old value is equal to the new value, it will skip the iteration.
    # 9. Then it will iterate through all the previous changes.
    # 10. And finally, it will add the changes to the description and increment the count.
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
    
    # The `process_action_text_changes` method is used to process the action text changes.
    #
    # Breaking down the `process_action_text_changes` method:
    #
    # 1. The `action_text_attributes` variable is used to store the action text attributes.
    # 2. The `each` method is used to iterate through the action text attributes.
    # 3. The `changes` variable is used to store the changes of the action text attributes.
    # 4. The `previous_content` variable is used to store the previous content of the action text attributes.
    # 5. The `current_content` variable is used to store the current content of the action text attributes.
    # 6. Then it will check if the previous content is blank.
    # 7. If the previous content is blank, it will skip the iteration.
    # 8. Then it will iterate through the previous items.
    # 9. And finally, it will add the changes to the description and increment the count.
    def process_action_text_changes
      action_text_attributes = {
        'meeting_objectives' => 'los objetivos de la reunión',
        'discussed_topics' => 'los temas discutidos',
        'pending_topics' => 'los temas pendientes',
        'meeting_notes' => 'las notas de la reunión',
        'agreements' => 'los acuerdos'
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

    # The `validate_attendees` method is used to validate the attendees of the minute.
    #
    # Breaking down the `validate_attendees` method:
    #
    # 1. The `validate_attendees` method is used to validate if nested attributes are empty.
    # 2. The `destroyed_attendees_validation` method is used to validate if all nested attributes are marked to be destroyed.
    # 3. The `duplicate_attendees_validation` method is used to validate if all nested attributes are marked to be destroyed.
    # 4. Finally, it will add an error message to the minute if the validation fails.
    def validate_attendees
      #validate if nested attributes are empty
      if params[:minute][:minutes_users_attributes].nil? || params[:minute][:minutes_users_attributes].empty?
        @minute.errors.add(:minutes_users, "es necesario seleccionar al menos un asistente")
      end

      #validate if all nested attributes are marked to be destroyed
      destroyed_attendees_validation

      #Duplicated attendees validation
      duplicate_attendees_validation
    end

    # The `destroyed_attendees_validation` method is used to validate if all nested attributes are marked to be destroyed.
    # 
    # Breaking down the `destroyed_attendees_validation` method:
    #
    # 1. The `deletedAssociations` variable is used to store the number of deleted associations.
    # 2. The `nested_attributes` variable is used to store the nested attributes.
    # 3. The `each` method is used to iterate through the nested attributes.
    # 4. The `destroy_value` variable is used to store the destroy value of the nested attributes.
    # 5. Then it will check if the destroy value is not equal to false.
    def destroyed_attendees_validation
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

    # The `duplicate_attendees_validation` method is used to validate if all nested attributes are marked to be destroyed.
    #
    # Breaking down the `duplicate_attendees_validation` method:
    #
    # 1. The `nested_attributes` variable is used to store the nested attributes.
    # 2. The `each` method is used to iterate through the nested attributes.
    # 3. The `user_ids` variable is used to store the user ids.
    # 4. Then it will check if the destroy value is not equal to false.
    # 5. Finally, it will add an error message to the minute if the validation fails.
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

    # The `validate_attendees_changes` method is used to validate the attendees changes.
    #
    # Breaking down the `validate_attendees_changes` method:
    #
    # 1. The `new_attributes` variable is used to store the new attributes.
    # 2. The `added_users` variable is used to store the added users.
    # 3. The `removed_users` variable is used to store the removed users.
    # 4. Then it will check if the removed users is not empty.
    # 5. If the removed users is not empty, it will add the removed users to the description.
    # 6. then it will add to the description the removed and added users.
    # 7. Finally, it will increment the count.
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
