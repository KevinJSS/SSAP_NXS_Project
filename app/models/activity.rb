class Activity < ApplicationRecord
    belongs_to :user
    belongs_to :project
    belongs_to :phase
end
