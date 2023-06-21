class Minute < ApplicationRecord
    #validations
    validates :meeting_title, presence: true, length: { in: 8..100 }
    validates :meeting_date, presence: true
    validates :start_time, presence: true
    validates :end_time, presence: true
    validate :start_time_greater_than_end_time
    validate :validate_attendees
    validate :duplicate_attendees

    def start_time_greater_than_end_time
        if start_time.present? && end_time.present? && end_time <= start_time
            errors.add(:end_time, "no puede ser menor a la hora inicial de la reunión")
        end
    end

    def get_meeting_duration
        duration = (self.end_time - self.start_time) / 1.hour
        duration.round(2) 
    end

    def validate_attendees
        if self.minutes_users.empty?
            errors.add(:minutes_users, "es necesario seleccionar al menos un asistente")
        end
    end

    def duplicate_attendees
        # nested_attributes = self.minutes_users
        # user_ids = nested_attributes.map(&:user_id)
        # duplicates = user_ids.select { |id| user_ids.count(id) > 1 }.uniq
        # if !duplicates.empty?
        #     errors.add(:minutes_users, "no puede haber asistentes duplicados")
        # end
    end

    #associations
    belongs_to :project

    has_many :minutes_users, dependent: :destroy
    has_many :users, through: :minutes_users
    accepts_nested_attributes_for :minutes_users, allow_destroy: true, reject_if: :all_blank
end
