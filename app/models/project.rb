class Project < ApplicationRecord
    belongs_to :user
    has_many :activities
    has_many :minutes
end
