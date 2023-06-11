class Activity < ApplicationRecord
    #validations
    validates :worked_hours, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 24 }
    validates :date, presence: true

    #associations
    belongs_to :user
    belongs_to :project
    belongs_to :phase
end
