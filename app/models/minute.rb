class Minute < ApplicationRecord
    # This method comes from the 'actiontext' gem and is used to define the rich text attributes of the model
    # The 'meeting_objectives', 'discussed_topics', 'pending_topics', 'agreements' and 'meeting_notes' attributes are rich text attributes
    has_rich_text :meeting_objectives
    has_rich_text :discussed_topics
    has_rich_text :pending_topics
    has_rich_text :agreements
    has_rich_text :meeting_notes

    # The 'before_destroy' callback is used to clean the changes log table before deleting a minute
    before_destroy :clean_changes

    # The 'before_save' callback is used to trim the values of the meeting_title attribute before saving the minute
    before_save :trim_values

    # The 'validates' method is used to validate the attributes of the model
    # The 'presence' option is used to validate that the attribute is not empty
    # The 'length' option is used to validate the length of the attribute
    validates :meeting_title, presence: true
    validates :meeting_title, length: { in: 8..100 }, if: -> { meeting_title.present? }
    validates :meeting_date, presence: true
    validates :start_time, presence: true
    validates :end_time, presence: true

    # The 'validate' method is used to validate the attributes of the model
    # The 'start_time_greater_than_end_time' method is used to validate that the end time is not less than or equal to the start time
    validate :start_time_greater_than_end_time
    # The 'validate_attendees' method is used to validate that the minute has at least one attendee
    validate :validate_attendees

    # The 'start_time_greater_than_end_time' method is used to validate that the end time is not less than or equal to the start time
    # If the end time is less than or equal to the start time, an error is added to the model
    def start_time_greater_than_end_time
        if start_time.present? && end_time.present?
            start_time_parsed = start_time.strftime("%Y-%m-%d %H:%M:%S")
            end_time_parsed = end_time.strftime("%Y-%m-%d %H:%M:%S")
        
            if Time.parse(end_time_parsed) <= Time.parse(start_time_parsed)
                errors.add(:end_time, "no puede ser menor o igual a la hora inicial de la reunión")
            end
        end
    end

    # The 'trim_values' method is used to trim the values of the meeting_title attribute before saving the minute
    def trim_values
        self.meeting_title = meeting_title.strip if meeting_title.present?
    end

    # The 'get_meeting_duration' method is used to get the duration of the minute
    # by subtracting the end time from the start time and dividing it by 1 hour
    def get_meeting_duration
        duration = (self.end_time - self.start_time) / 1.hour
        formatted_duration = sprintf("%.1f", duration)
        formatted_duration.to_f
    end

    # The validate_attendees method is used to validate that the minute has at least one attendee
    # If the minute has no attendees, an error is added to the model
    def validate_attendees
        if self.minutes_users.empty?
            errors.add(:minutes_users, "es necesario seleccionar al menos un asistente")
        end
    end

    # The self.ransackable_attributes method is used to search for attributes of the model
    # The 'meeting_date', 'project_id' and 'meeting_title' attributes are allowed to search
    def self.ransackable_attributes(auth_object = nil)
        ["meeting_date", "project_id", "meeting_title"]
    end

    # The clean_changes method is used to clean the changes log table before deleting a minute
    # The 'where' method is used to get the changes log of the minute and destroy them before deleting the minute
    def clean_changes
        ChangeLog.where(table_id: self.id, table_name: "minute").destroy_all
    end

    # The 'belongs_to' method is used to define the relationship between the minute and the project
    belongs_to :project

    # The 'has_many' method is used to define the relationship between the minute and the minutes_users
    # The 'dependent' option is used to delete the minutes_users of the minute when the minute is deleted
    # The 'through' option is used to define the relationship between the minute and the users
    # The 'accepts_nested_attributes_for' method is used to accept the nested attributes for the minutes_users
    # The 'allow_destroy' option is used to allow the destruction of the minutes_users
    # The 'reject_if' option is used to reject the minutes_users if the attributes are blank
    has_many :minutes_users, dependent: :destroy
    has_many :users, through: :minutes_users
    accepts_nested_attributes_for :minutes_users, allow_destroy: true, reject_if: :all_blank
end
