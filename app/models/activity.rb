class Activity < ApplicationRecord
    # The 'before_destroy' callback is used to clean the changes log table before deleting an activity
    before_destroy :clean_changes

    # The 'validates' method is used to validate the attributes of the model
    # The 'presence' option is used to validate that the attribute is not empty
    validates :date, presence: true

    # The 'validate' method is used to validate the attributes of the model
    # The 'date_lower_than_or_equal_to_today' method is used to validate that the date is not greater than today
    validate :date_lower_than_or_equal_to_today

    # The 'validate_nested_phases' method is used to validate that the activity has at least one phase
    validate :validate_nested_phases

    # The 'date_lower_than_or_equal_to_today' method is used to validate that the date is not greater than today
    def date_lower_than_or_equal_to_today
        if date.present? && date > Date.today
            errors.add(:date, "no puede ser mayor a la fecha de hoy")
        end
    end

    # The 'validate_nested_phases' method is used to validate that the activity has at least one phase
    # If the activity has no phases, an error is added to the model
    def validate_nested_phases
        if self.phases_activities.empty?
            errors.add(:phases_activities, "es necesario agregar al menos una actividad y horas realizadas")
        end
    end

    # The 'get_total_hours' method is used to get the total hours of the activity
    # The 'sum' method is used to sum the hours of the phases_activities of the activity
    def get_total_hours
        self.phases_activities.sum(:hours)
    end

    # The self.ransackable_attributes method is used to search for attributes of the model
    # The 'date', 'project_id' and 'user_id' attributes are allowed to search
    def self.ransackable_attributes(auth_object = nil)
        ["date", "project_id", "user_id"]
    end

    # The clean_changes method is used to clean the changes log table before deleting an activity
    # The 'where' method is used to get the changes log of the activity and destroy them before deleting the activity
    def clean_changes
        ChangeLog.where(table_id: self.id, table_name: "activity").destroy_all
    end

    # The 'belongs_to' method is used to define the relationship between the activity and the user
    belongs_to :user

    # The 'belongs_to' method is used to define the relationship between the activity and the project
    belongs_to :project

    # The 'has_many' method is used to define the relationship between the activity and the phases_activities
    # The 'dependent' option is used to delete the phases_activities of the activity when the activity is deleted
    # The 'through' option is used to define the relationship between the activity and the phases
    # The 'accepts_nested_attributes_for' method is used to accept the nested attributes for the phases_activities
    # The 'allow_destroy' option is used to allow the destruction of the phases_activities
    # The 'reject_if' option is used to reject the phases_activities if the attributes are blank
    has_many :phases_activities, dependent: :destroy
    has_many :phases, through: :phases_activities
    accepts_nested_attributes_for :phases_activities, allow_destroy: true, reject_if: :all_blank
end
