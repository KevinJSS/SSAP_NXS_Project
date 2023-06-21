class MinutesUser < ApplicationRecord
  #validations
  validates :user_id, presence: true

  # Associations
  belongs_to :minute
  belongs_to :user
end
