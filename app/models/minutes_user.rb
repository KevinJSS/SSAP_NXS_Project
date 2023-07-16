class MinutesUser < ApplicationRecord
  # The 'validates' method is used to validate the attributes of the model
  # The 'presence' option is used to validate that the attribute is not empty
  validates :user_id, presence: true

  # The 'belongs_to' method is used to define the relationship between the minutes_user and the minute
  # A minutes_user belongs to a minute and also belongs to a user
  belongs_to :minute
  belongs_to :user
end
