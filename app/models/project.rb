class Project < ApplicationRecord
    enum :stage, { 
        conceptual_design: 0, 
        arch_design: 1, 
        eng_design: 2,
        approvals: 3, 
        contracting: 4, 
        construction: 5, 
        completition_delivery: 6 
    }

    enum :stage_status, {
        pending: 0,
        in_process: 1,
        approved: 2,
        denied: 3,
        finished: 4
   }

    #input validations
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
            errors.add(:scheduled_deadline, "must be greater than the start date")
        end
    end

    def get_stage_options
        stage_options = [
            ["Diseño conceptual", :conceptual_design],
            ["Diseño arquitectónico", :arch_design],
            ["Diseño de ingeniería", :eng_design],
            ["Permisos y aprovaciones", :approvals],
            ["Licitación y contratación", :contracting],
            ["Construcción", :construction],
            ["Finalización y entrega", :completion_delivery]
        ]
    end

    def get_status_options
        status_options = [
            ["Pendiente", :pending],
            ["En proceso", :in_process],
            ["Aprobado", :approved],
            ["Rechazado", :denied],
            ["Finalizado", :finished]
        ]
    end

    def get_humanize_stage
        stage_options = self.get_stage_options

        stage_options.each do |stage|
          @stage = stage[0] if stage[1].to_s == self.stage 
        end

        @stage
    end

    def get_humanize_status
        status_options = self.get_status_options

        status_options.each do |status|
          @status = status[0] if status[1].to_s == self.stage_status 
        end

        @status
    end

    #associations
    belongs_to :user
    has_many :activities
    has_many :minutes
end
