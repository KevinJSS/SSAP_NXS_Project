class Minute < ApplicationRecord
    has_rich_text :meeting_objectives
    has_rich_text :discussed_topics
    has_rich_text :pending_topics
    has_rich_text :agreements
    has_rich_text :meeting_notes

    #validations
    before_destroy :clean_changes

    validates :meeting_title, presence: true
    validates :meeting_title, length: { in: 8..100 }, if: -> { meeting_title.present? }
    validates :meeting_date, presence: true
    validates :start_time, presence: true
    validates :end_time, presence: true
    validate :start_time_greater_than_end_time
    validate :validate_attendees

    def start_time_greater_than_end_time
        if start_time.present? && end_time.present? && end_time <= start_time
            errors.add(:end_time, "no puede ser menor a la hora inicial de la reunión")
        end
    end

    def get_meeting_duration
        duration = (self.end_time - self.start_time) / 1.hour
        formatted_duration = sprintf("%.1f", duration)
        formatted_duration.to_f
    end

    def validate_attendees
        if self.minutes_users.empty?
            errors.add(:minutes_users, "es necesario seleccionar al menos un asistente")
        end
    end

    def self.ransackable_attributes(auth_object = nil)
        ["meeting_date", "project_id", "meeting_title"]
    end

    def clean_changes
        ChangeLog.where(table_id: self.id, table_name: "minute").destroy_all
    end

    #associations
    belongs_to :project

    has_many :minutes_users, dependent: :destroy
    has_many :users, through: :minutes_users
    accepts_nested_attributes_for :minutes_users, allow_destroy: true, reject_if: :all_blank
end
