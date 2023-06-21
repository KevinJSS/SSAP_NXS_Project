class Activity < ApplicationRecord
    #validations
    validates :date, presence: true
    validate :date_lower_than_or_equal_to_today
    validate :validate_nested_phases
    validate :duplicate_phases
    validate :min_max_total_hours

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

    def duplicate_phases
        nested_attributes = self.phases_activities
        phase_ids = nested_attributes.map(&:phase_id)
        duplicates = phase_ids.select { |id| phase_ids.count(id) > 1 }.uniq
        if !duplicates.empty?
            errors.add(:phases_activities, "no puede haber fases duplicadas")
        end
    end

    def get_total_hours
        self.phases_activities.sum(:hours)
    end

    def min_max_total_hours
        total_hours = get_total_hours
        if total_hours < 1 || total_hours > 24
            errors.add(:phases_activities, "el total de horas debe estar entre 1 y 24")
        end
    end

    #associations
    belongs_to :user
    belongs_to :project
    #belongs_to :phase

    has_many :phases_activities, dependent: :destroy
    has_many :phases, through: :phases_activities
    accepts_nested_attributes_for :phases_activities, allow_destroy: true, reject_if: :all_blank
end
