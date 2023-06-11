class Phase < ApplicationRecord
    #validations
    validates :code, presence: true, uniqueness: true, length: { in: 1..50}
    validates :code, presence: true, length: { in: 1..100}

    def has_associated_activities?
        activities = self.activities.count
        activities != 0
    end

    #associations
    has_many :activities
end
