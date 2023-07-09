class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  enum :role, [:collaborator, :admin]

  enum :id_card_type, {
    person: 0,
    residence: 1,
    passport: 2,
    work_permit: 3,
    dimex: 4
  }

  enum :gender, {
    male: 0,
    female: 1,
    not_specified: 2
  }

  enum :marital_status, {
    single: 0,
    married: 1,
    separated: 2,
    divorced: 3,
    widowed: 4,
    unmarried: 5,
    cohabiting: 6
  }

  enum :education, {
    no_degree: 0,
    primary: 1,
    secondary: 2,
    university: 3,
    postgraduate: 4,
  }

  #validations & format
  # This is a regular expression that matches the RFC 5322 standard for email addresses.
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  #input validations
  before_save { self.email = email.downcase }
  before_save { self.fullname = fullname.upcase }
  before_save { self.province = province.upcase }
  before_save { self.canton = canton.upcase }
  before_save { self.district = district.upcase }
  before_save { self.nationality = nationality.upcase }
  before_save { self.account_number = account_number.upcase }
  before_save { self.id_card = id_card.upcase }
  before_save :trim_values
  before_destroy :clean_changes

  validates :email, presence: true, uniqueness: true, length: { maximum: 100 }, format: { with: VALID_EMAIL_REGEX }
  validates :id_card_type, presence: true
  validates :id_card, presence: true, uniqueness: true, length: { in: 8..15 } 
  validates :fullname, presence: true, length: { in: 5..100 }
  validates :birth_date, presence: true
  validates :marital_status, presence: true
  validates :education, presence: true
  validates :phone, presence: true, length: { in: 8..20 }
  validates :address, length: { maximum: 200 }
  validates :province, presence: true, length: { in: 2..50 }
  validates :canton, presence: true, length: { in: 2..50 }
  validates :district, presence: true, length: { in: 2..50 }
  validates :job_position, presence: true, length: { in: 4..100 }
  validates :account_number, length: { maximum: 100 }
  validate :birth_date_validation

  def trim_values
    self.email = email.strip if email.present?
    self.fullname = fullname.strip if fullname.present?
    self.phone = phone.strip if phone.present?
    self.id_card = id_card.strip if id_card.present?
    self.job_position = job_position.strip if job_position.present?
    self.address = address.strip if address.present?
    self.province = province.strip if province.present?
    self.canton = canton.strip if canton.present?
    self.district = district.strip if district.present?
  end

  def birth_date_validation
    return unless birth_date.present?

    if birth_date > Date.today
      errors.add(:birth_date, "no puede ser mayor a la fecha actual")
    end

    if birth_date > 18.years.ago.to_date
      errors.add(:birth_date, "debe ser mayor de 18 años")
    end
  end

  def get_id_card_types
    id_card_options = [
        ["Persona física", :person],
        ["Cédula de residencia", :residence],
        ["Pasaporte", :passport],
        ["Permiso de trabajo", :work_permit],
        ["DIMEX", :dimex]
    ]
  end

  def get_gender_options
    gender_options = [
        ["Masculino", :male],
        ["Femenino", :female],
        ["No especifico", :not_specified]
    ]
  end

  def get_marital_status_options
    marital_status_options = [
        ["Soltero(a)", :single],
        ["Casado(a)", :married],
        ["Separado(a)", :separated],
        ["Divorciado(a)", :divorced],
        ["Viudo(a)", :widowed],
        ["Célibe", :unmarried],
        ["Unión libre", :cohabiting],
    ]
  end

  def get_education_options
    education_options = [
        ["Sin grado académico", :no_degree],
        ["Primaria", :primary],
        ["Secundaria", :secondary],
        ["Universidad", :university],
        ["Posgrado universitario", :postgraduate]
    ]
  end

  def get_humanize_id_card_type(t = nil)
    t ||= self.id_card_type
    id_card_options = self.get_id_card_types

    id_card_options.each do |id_card_type|
      @id_card_type = id_card_type[0] if id_card_type[1].to_s == t.to_s
    end

    @id_card_type
  end

  def get_humanize_gender(g = nil)
    g ||= self.gender
    gender_options = self.get_gender_options

    gender_options.each do |gender|
      @gender = gender[0] if gender[1].to_s == g.to_s
    end

    @gender
  end

  def get_humanize_marital_status(m = nil)
    m ||= self.marital_status
    marital_status_options = self.get_marital_status_options

    marital_status_options.each do |marital_status|
      @marital_status = marital_status[0] if marital_status[1].to_s == m.to_s 
    end

    @marital_status
  end

  def get_humanize_education(e = nil)
    e ||= self.education
    education_options = self.get_education_options

    education_options.each do |education|
      @education = education[0] if education[1].to_s == e.to_s
    end

    @education
  end

  def get_short_name
    fullname = self.fullname.split(" ")
    short_name = fullname[0] + " " + fullname[1]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["account_number", "address", "birth_date", "canton", "created_at", "district", "education", "email", "encrypted_password", "fullname", "gender", "id", "id_card", "id_card_type", "job_position", "marital_status", "nationality", "phone", "province", "remember_created_at", "reset_password_sent_at", "reset_password_token", "role", "status", "updated_at"]
  end

  def clean_changes
    ChangeLog.where(table_id: self.id, table_name: "user").destroy_all
  end
  
  #associations
  has_many :projects
  
  has_one :emergency_contact, dependent: :destroy
  accepts_nested_attributes_for :emergency_contact, allow_destroy: true, reject_if: :all_blank

  has_many :activities

  has_many :minutes_users, dependent: :destroy
  has_many :minutes, through: :minutes_users

  has_many :assigned_tasks

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable
end
