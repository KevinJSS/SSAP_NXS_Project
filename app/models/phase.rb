class Phase < ApplicationRecord
    #validations
    before_destroy :clean_changes
    before_save :trim_values
    validates :code, presence: true, uniqueness: true
    validates :code, length: { in: 2..50}, if: -> { code.present? }
    validates :name, presence: true
    validates :name, length: { in: 5..100}, if: -> { name.present? }

    def has_associated_activities?
        activities = self.activities.count
        activities != 0
    end

    def trim_values
        self.code = code.strip if code.present?
        self.name = name.strip if name.present?
    end

    def self.ransackable_associations(auth_object = nil)
        ["activities"]
    end

    def self.ransackable_attributes(auth_object = nil)
        ["code", "name"]
    end

    def clean_changes
        ChangeLog.where(table_id: self.id, table_name: "phase").destroy_all
    end

    #associations
    has_many :phases_activities, dependent: :destroy
    has_many :activities, through: :phases_activities
end
