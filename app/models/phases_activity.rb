class PhasesActivity < ApplicationRecord
  # The 'validates' method is used to validate the attributes of the model
  # The 'presence' option is used to validate that the attribute is not empty
  # The 'numericality' option is used to validate that the attribute is a number
  # The 'greater_than_or_equal_to' option is used to validate that the attribute is greater than or equal to the specified value
  # The 'less_than_or_equal_to' option is used to validate that the attribute is less than or equal to the specified value
  validates :phase_id, presence: true
  validates :hours, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 24 }

  # The 'belongs_to' method is used to define the relationship between the phases_activity and the phase
  # A phases_activity belongs to a phase and also belongs to an activity
  belongs_to :phase
  belongs_to :activity
end
