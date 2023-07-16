class Project < ApplicationRecord
    # Enums define the possible values for the `stage` and `stage_status` attributes.
    # The `stage` attribute can only be one of the following values:
    enum :stage, { 
        initial_meetings: 0, 
        preliminary_studies: 1, 
        preliminary_design: 2,
        technical_specifications: 3, 
        project_management: 4,
        construction: 5, 
        technical_supervision: 6, 
        construction_inspection: 7,
        finished: 8
    }

    enum :stage_status, {
        in_process: 0,
        suspended: 1,
        delivered: 2
    }

    # The `before_save` callback method ensures that the `name` attribute is always
    before_save { self.name = name.upcase }

    # Before saving, trims leading and trailing whitespace from name and location attributes.
    before_save :trim_values

    # Before destroying a project, it removes all associated changes from the `ChangeLog` model.
    before_destroy :clean_changes

    # The `validates` method is used to validate the presence and length of the `name` and `location` attributes.
    validates :name, presence: true
    validates :name, length: { in: 2..100 }, if: -> { name.present? }

    validates :location, presence: true
    validates :location, length: { in: 2..500 }, if: -> { location.present? }
    
    # The `validates` method is used to validate the presence of the `start_date` and `scheduled_deadline` attributes.
    validates :start_date, presence: true
    validates :scheduled_deadline, presence: true

    # The `validates` method is used to validate the presence of the `stage` and `stage_status` attributes.
    validates :stage, presence: true
    validates :stage_status, presence: true

    # The validation below ensures that the `scheduled_deadline` attribute is greater than the `start_date` attribute.
    validate :deadline_greater_than_start_date

    # The trim_values method is used to trim leading and trailing whitespace from the `name` and `location` attributes.
    def trim_values
        self.name = name.strip if name.present?
        self.location = location.strip if location.present?
    end

    # The deadline_greater_than_start_date method is used to validate that the `scheduled_deadline` attribute is greater than the `start_date` attribute.
    def deadline_greater_than_start_date
        if start_date.present? && scheduled_deadline.present? && scheduled_deadline <= start_date
            errors.add(:scheduled_deadline, "debe ser mayor a la fecha de inicio")
        end
    end

    # The get_stage_options method returns an array of arrays containing the humanized stage and its corresponding value.
    def get_stage_options
        stage_options = [
            ["Visitas y reuniones iniciales", :initial_meetings],
            ["Estudios preliminares", :preliminary_studies],
            ["Anteproyecto", :preliminary_design],
            ["Planos y especificaciones técnicas", :technical_specifications],
            ["Presupuesto y dirección de obra", :project_management],
            ["Construcción", :construction],
            ["Dirección técnica", :technical_supervision],
            ["Inspección de obra", :construction_inspection],
            ["Proyecto finalizado", :finished]
        ]
    end

    # The get_status_options method returns an array of arrays containing the humanized status and its corresponding value.
    def get_status_options
        status_options = [
            ["En proceso", :in_process],
            ["Suspendido", :suspended],
            ["Entregado", :delivered]
        ]
    end

    # The get_humanize_stage method returns the humanized stage value for the current project.
    def get_humanize_stage(stage_value = nil)
        stage_value ||= self.stage

        stage_options = get_stage_options
        humanized_stage = nil
      
        stage_options.each do |stage|
          humanized_stage = stage[0] if stage[1].to_s == stage_value.to_s
        end
      
        humanized_stage
    end

    # The get_humanize_status method returns the humanized status value for the current project.
    def get_humanize_status(status_value = nil)
        status_value ||= self.stage_status
        status_options = self.get_status_options

        status_options.each do |status|
          @status = status[0] if status[1].to_s == status_value.to_s
        end

        @status
    end

    # The has_associated_minutes_and_activities? method returns true if the current project has associated minutes or activities.
    def has_associated_minutes_and_activities?
        minutes = self.minutes.count
        activities = self.activities.count
        activities != 0 || minutes != 0
    end

    # The self.ransackable_associations method is used to allow the `ransack` gem to search through the `activities`, `minutes`, and `user` associations.
    def self.ransackable_associations(auth_object = nil)
        ["activities", "minutes", "user"]
    end

    # The self.ransackable_attributes method is used to allow the `ransack` gem to search through the `name`, `stage`, `stage_status`, and `user_id` attributes.
    def self.ransackable_attributes(auth_object = nil)
        ["name", "stage", "stage_status", "user_id"]
    end

    # The self.ransortable_attributes method is used to allow the `ransack` gem to sort through the `name`, `stage`, `stage_status`, and `user_id` attributes.
    def clean_changes
        ChangeLog.where(table_id: self.id, table_name: "project").destroy_all
    end

    # Associations between the `Project`, `Activity`, `Minute`, and `User` models.
    # A project `has_many` activities and minutes, and `belongs_to` a user.
    belongs_to :user
    has_many :activities, dependent: :destroy
    has_many :minutes, dependent: :destroy
end
