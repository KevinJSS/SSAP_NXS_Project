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

    #associations
    belongs_to :user
    has_many :activities
    has_many :minutes
end
