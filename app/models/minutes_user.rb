class MinutesUser < ApplicationRecord
  belongs_to :minute
  belongs_to :user
end
