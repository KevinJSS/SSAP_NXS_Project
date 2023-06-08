class Minute < ApplicationRecord
    belongs_to :project

    has_many :minutes_users
    has_many :users, through: :minutes_users
end
