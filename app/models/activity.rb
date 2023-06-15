class Activity < ApplicationRecord
    before_save :remove_duplicate_phases

    #validations
    validates :worked_hours, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 24 }
    validates :date, presence: true
    validates :nested_phases, presence: true, inclusion: { in: [true], message: "debe seleccionar al menos una fase." }
    validate :nested_phases_array
    validate :date_lower_than_or_equal_to_today

    def date_lower_than_or_equal_to_today
        if date.present? && date > Date.today
            errors.add(:date, "La fecha no puede ser mayor a la fecha de hoy")
        end
    end

    def remove_duplicate_phases
        self.phase_ids = self.phase_ids.uniq
    end

    def nested_phases_array
        return unless nested_phases == true
        if phase_ids.blank?
            errors.add(:nested_phases, "debe seleccionar al menos una fase.")
        end
    end

    #associations
    belongs_to :user
    belongs_to :project
    #belongs_to :phase

    has_and_belongs_to_many :phases
end
