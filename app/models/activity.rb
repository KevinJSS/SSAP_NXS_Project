class Activity < ApplicationRecord
    #validations
    validates :date, presence: true
    validate :date_lower_than_or_equal_to_today
    validate :validate_nested_phases

    def date_lower_than_or_equal_to_today
        if date.present? && date > Date.today
            errors.add(:date, "La fecha no puede ser mayor a la fecha de hoy")
        end
    end

    def validate_nested_phases
        if self.phases_activities.empty?
            errors.add(:phases_activities, "es necesario seleccionar al menos una fase y horas realizadas")
        end
    end

    def get_total_hours
        self.phases_activities.sum(:hours)
    end

    #associations
    belongs_to :user
    belongs_to :project
    #belongs_to :phase

    has_many :phases_activities, dependent: :destroy
    has_many :phases, through: :phases_activities
    accepts_nested_attributes_for :phases_activities, allow_destroy: true, reject_if: :all_blank
end
