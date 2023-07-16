class Phase < ApplicationRecord
    # The 'before_destroy' callback is invoked by the 'destroy' method in the controller.
    # This callback is used to delete the associated activities before deleting the phase.
    before_destroy :clean_changes

    # The 'before_save' callback is invoked by the 'save' method in the controller.
    # This callback is used to trim the values of the attributes before saving the phase.
    before_save :trim_values

    # The 'validates' method is used to validate the attributes of the model.
    # The 'presence' validation ensures that the specified attributes are not empty.
    # The 'uniqueness' validation ensures that the specified attributes are unique.
    # The 'length' validation ensures that the specified attributes are within the specified length.
    # The 'if' option is used to specify the condition to be met for the validation to be executed.
    validates :code, presence: true, uniqueness: true
    validates :code, length: { in: 2..50}, if: -> { code.present? }
    validates :name, presence: true
    validates :name, length: { in: 5..100}, if: -> { name.present? }

    # The 'has_associated_activities?' method is used to check if the phase has associated activities.
    # The 'count' method is used to count the number of associated activities.
    # The 'has_associated_activities?' method returns true if the phase has associated activities.
    def has_associated_activities?
        activities = self.activities.count
        activities != 0
    end

    # The 'trim_values' method is used to trim the values of the attributes before saving the phase.
    # The 'strip' method is used to remove the leading and trailing whitespaces from the attributes.
    def trim_values
        self.code = code.strip if code.present?
        self.name = name.strip if name.present?
    end

    # The 'self.ransackable_associations' method is used to specify the associations that can be searched.
    def self.ransackable_associations(auth_object = nil)
        ["activities"]
    end

    # The 'self.ransackable_attributes' method is used to specify the attributes that can be searched.
    def self.ransackable_attributes(auth_object = nil)
        ["code", "name"]
    end

    def clean_changes
        ChangeLog.where(table_id: self.id, table_name: "phase").destroy_all
    end

    # Associations between the phase and other models.
    # A phase has many activities, through the phases_activities model.
    # The dependent option is used to delete the associated activities and phases_activities before deleting the phase.
    has_many :phases_activities, dependent: :destroy
    has_many :activities, through: :phases_activities
end
