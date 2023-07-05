class Phase < ApplicationRecord
    #validations
    validates :code, presence: true, uniqueness: true, length: { in: 1..50}
    validates :code, presence: true, length: { in: 1..100}

    def has_associated_activities?
        activities = self.activities.count
        activities != 0
    end

    def self.ransackable_associations(auth_object = nil)
        ["activities"]
    end

    def self.ransackable_attributes(auth_object = nil)
        ["code", "name"]
    end

    #associations
    has_many :phases_activities, dependent: :destroy
    has_many :activities, through: :phases_activities
end
