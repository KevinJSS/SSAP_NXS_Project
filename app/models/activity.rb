class Activity < ApplicationRecord
    #validations
    validates :worked_hours, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 24 }
    validates :date, presence: true
    validate :date_lower_than_or_equal_to_today

    def date_lower_than_or_equal_to_today
        if date.present? && date > Date.today
            errors.add(:date, "La fecha no puede ser mayor al día de hoy")
        end
    end

    #associations
    belongs_to :user
    belongs_to :project
    belongs_to :phase
end
