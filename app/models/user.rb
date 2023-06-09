class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  
  #validations & format
  # This is a regular expression that matches the RFC 5322 standard for email addresses.
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  #input validations
  before_save { self.email = email.downcase }
  before_save { self.fullname = fullname.upcase }
  before_save { self.id_card = id_card.upcase }
  before_save :trim_values

  validates :email, presence: true, uniqueness: true, length: { maximum: 100 }, format: { with: VALID_EMAIL_REGEX }
  validates :id_card, presence: true, uniqueness: true, length: { in: 8..12 }, uniqueness: true 
  validates :fullname, presence: true, length: { in: 5..100 }
  validates :phone, presence: true, length: { in: 8..20 }
  validates :address, presence: true, length: { maximum: 200 }
  validates :job_position, presence: true, length: { in: 4..20 }

  def trim_values
    self.email = email.strip if email.present?
    self.fullname = fullname.strip if fullname.present?
    self.phone = phone.strip if phone.present?
    self.id_card = id_card.strip if id_card.present?
    self.job_position = job_position.strip if job_position.present?
    self.address = address.strip if address.present?
  end
  
  #associations
  has_many :projects
  
  has_one :emergency_contact
  accepts_nested_attributes_for :emergency_contact

  has_many :activities

  has_many :minutes_users
  has_many :minutes, through: :minutes_users

  has_many :assigned_tasks

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, [:worker, :admin]

  # def set_default_role
  #   self.role ||= :worker
  # end
end
