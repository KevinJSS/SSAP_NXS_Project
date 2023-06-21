class Minute < ApplicationRecord
    #validations
    validates :meeting_title, presence: true, length: { in: 8..100 }
    validates :meeting_date, presence: true
    validates :start_time, presence: true
    validates :end_time, presence: true
    validate :start_time_greater_than_end_time

    def start_time_greater_than_end_time
        if start_time.present? && end_time.present? && end_time <= start_time
            errors.add(:end_time, "no puede ser menor a la hora inicial de la reunión")
        end
    end

    def get_meeting_duration
        duration = (self.end_time - self.start_time) / 1.hour
        duration.round(2) 
    end

    #associations
    belongs_to :project

    has_many :minutes_users, dependent: :destroy
    has_many :users, through: :minutes_users
    accepts_nested_attributes_for :minutes_users, allow_destroy: true, reject_if: :all_blank
end
