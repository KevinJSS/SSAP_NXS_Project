class Project < ApplicationRecord
    enum :stage, { 
        initial_meetings: 0, 
        preliminary_studies: 1, 
        preliminary_design: 2,
        technical_specifications: 3, 
        project_management: 4,
        construction: 5, 
        technical_supervision: 6, 
        construction_inspection: 7
    }

    enum :stage_status, {
        in_process: 0,
        suspended: 1,
        delivered: 2
    }

    #validations
    before_save { self.name = name.upcase }
    before_save :trim_values

    validates :name, presence: true, length: { in: 2..100}
    validates :start_date, presence: true
    validates :scheduled_deadline, presence: true
    validates :location, presence: true, length: { in: 2..500}
    validates :stage, presence: true
    validates :stage_status, presence: true
    validate :deadline_greater_than_start_date

    def trim_values
        self.name = name.strip if name.present?
        self.location = location.strip if location.present?
    end

    def deadline_greater_than_start_date
        if start_date.present? && scheduled_deadline.present? && scheduled_deadline <= start_date
            errors.add(:scheduled_deadline, "debe ser mayor a la fecha de inicio")
        end
    end

    def get_stage_options
        stage_options = [
            ["Visitas y reuniones iniciales", :initial_meetings],
            ["Estudios preliminares", :preliminary_studies],
            ["Anteproyecto", :preliminary_design],
            ["Planos y especificaciones técnicas", :technical_specifications],
            ["Presupuesto y dirección de obra", :project_management],
            ["Construcción", :construction],
            ["Dirección técnica", :technical_supervision],
            ["Inspección de obra", :construction_inspection]
        ]
    end

    def get_status_options
        status_options = [
            ["En proceso", :in_process],
            ["Suspendido", :suspended],
            ["Entregado", :delivered]
        ]
    end

    def get_humanize_stage(stage_value = nil)
        stage_value ||= self.stage

        stage_options = get_stage_options
        humanized_stage = nil
      
        stage_options.each do |stage|
          humanized_stage = stage[0] if stage[1].to_s == stage_value.to_s
        end
      
        humanized_stage
    end

    def get_humanize_status(status_value = nil)
        status_value ||= self.stage_status
        status_options = self.get_status_options

        status_options.each do |status|
          @status = status[0] if status[1].to_s == status_value.to_s
        end

        @status
    end

    def has_associated_minutes_and_activities?
        minutes = self.minutes.count
        activities = self.activities.count
        activities != 0 || minutes != 0
    end

    def self.ransackable_associations(auth_object = nil)
        ["activities", "minutes", "user"]
    end

    def self.ransackable_attributes(auth_object = nil)
        ["name", "stage", "stage_status", "user_id"]
    end

    #associations
    belongs_to :user
    has_many :activities, dependent: :destroy
    has_many :minutes, dependent: :destroy
end
