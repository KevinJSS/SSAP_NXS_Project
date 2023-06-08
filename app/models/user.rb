class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :projects
  has_one :emergency_contact
  has_many :activities

  has_many :minutes_users
  has_many :minutes, through: :minutes_users

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
