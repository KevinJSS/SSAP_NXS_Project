class PhasesActivity < ApplicationRecord

  #validations
  validates :phase_id, presence: true
  validates :hours, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 24 }

  # Associations
  belongs_to :phase
  belongs_to :activity
end
