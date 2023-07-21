class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  # The 'enum' method is used to define the enumerations of the model
  # The 'role' enumeration is used to define the roles of the users
  enum :role, [:collaborator, :admin]

  # The id_card_type enumeration is used to define the types of identification cards
  enum :id_card_type, {
    person: 0,
    residence: 1,
    passport: 2,
    work_permit: 3,
    dimex: 4
  }

  # The gender enumeration is used to define the possible gender that a user can have
  enum :gender, {
    male: 0,
    female: 1,
    not_specified: 2
  }

  # The marital_status enumeration is used to define the possible marital status that a user can have
  enum :marital_status, {
    single: 0,
    married: 1,
    separated: 2,
    divorced: 3,
    widowed: 4,
    unmarried: 5,
    cohabiting: 6
  }

  # The education enumeration is used to define the possible education that a user can have
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

  # The 'before_save' callback is used to set the email attribute to lowercase before saving the user
  # In this case, it will take all received input values and formatted them for a more consistent database.
  before_save { self.email = email.downcase }
  before_save { self.fullname = fullname.upcase }
  before_save { self.province = province.upcase }
  before_save { self.canton = canton.upcase }
  before_save { self.district = district.upcase }
  before_save { self.nationality = nationality.upcase }
  before_save { self.account_number = account_number.upcase }
  before_save { self.id_card = id_card.upcase }

  # The 'before_save' callback is used to trim the values of the email, fullname, phone, id_card, job_position, address, province, canton and district attributes before saving the user
  before_save :trim_values

  # The 'before_destroy' callback is used to clean the changes log table before deleting a user
  before_destroy :clean_changes

  # The 'validates' method is used to validate the attributes of the model
  # The 'presence' option is used to validate that the attribute is not empty
  # The 'uniqueness' option is used to validate that the attribute is unique
  # The 'format' option is used to validate that the attribute matches the regular expression
  # The 'length' option is used to validate the length of the attribute
  # The 'if' option is used to validate the attribute if the condition is true
  # The 'allow_blank' option is used to validate the attribute if the attribute is blank
  # The 'numericality' option is used to validate that the attribute is a number
  # The 'greater_than_or_equal_to' option is used to validate that the attribute is greater than or equal to the specified value
  # The 'less_than_or_equal_to' option is used to validate that the attribute is less than or equal to the specified value
  validates :email, presence: true, uniqueness: true, format: { with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i }, if: -> { email.present? }
  validates :id_card_type, presence: { message: "debe ser indicado." }
  validates :id_card, presence: true
  validates :id_card, length: { in: 8..15 }, if: -> { id_card.present? }
  validates :fullname, presence: true
  validates :fullname, length: { in: 5..100 }, if: -> { fullname.present? }
  validates :birth_date, presence: true
  validates :marital_status, presence: true
  validates :education, presence: true
  validates :phone, presence: true
  validates :phone, length: { in: 8..20 }, if: -> { phone.present? }
  validates :address, length: { maximum: 200 }
  validates :province, presence: true
  validates :province, length: { in: 2..50 }, if: -> { province.present? }
  validates :canton, presence: true
  validates :canton, length: { in: 2..50 }, if: -> { canton.present? }
  validates :district, presence: true
  validates :district, length: { in: 2..50 }, if: -> { district.present? }
  validates :job_position, presence: true
  validates :job_position, length: { in: 4..100 }, if: -> { job_position.present? }
  validates :account_number, length: { maximum: 100 }
  validate :validate_id_card

  # The 'validate' method is used to validate the attributes of the model
  # The 'birth_date_validation' method is used to validate that the birth date is not greater than today and that the user is over 18 years old
  validate :birth_date_validation

  # The 'trim_values' method is used to trim the values of the email, fullname, phone, id_card, job_position, address, province, 
  # canton and district attributes before saving the user
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

  def validate_id_card
    return if !self.new_record? || self.id_card.blank?

    formated_id_card = self.id_card.strip.upcase

    if User.where(id_card: formated_id_card).exists?
      errors.add(:id_card, "ya se encuentra en uso")
    end
  end

  # The 'birth_date_validation' method is used to validate that the birth date is not greater than today and that the user is over 18 years old
  # If the birth date is greater than today, an error is added to the model
  def birth_date_validation
    return unless birth_date.present?

    if birth_date > Date.today
      errors.add(:birth_date, "no puede ser mayor a la fecha actual")
    end

    if birth_date > 18.years.ago.to_date
      errors.add(:birth_date, "debe ser mayor de 18 años")
    end
  end

  # The 'get_id_card_types' method is used to get the id card types of the user in a list
  def get_id_card_types
    id_card_options = [
        ["Persona física", :person],
        ["Cédula de residencia", :residence],
        ["Pasaporte", :passport],
        ["Permiso de trabajo", :work_permit],
        ["DIMEX", :dimex]
    ]
  end

  # The get_gender_options method is used to get que gender options of a user in a list
  def get_gender_options
    gender_options = [
        ["Masculino", :male],
        ["Femenino", :female],
        ["No especifico", :not_specified]
    ]
  end

  # The get_marital_status_options method is used to get the marital status options of a user in a list
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

  # The get_education_options method is used to get the education options of a user in a list
  def get_education_options
    education_options = [
        ["Sin grado académico", :no_degree],
        ["Primaria", :primary],
        ["Secundaria", :secondary],
        ["Universidad", :university],
        ["Posgrado universitario", :postgraduate]
    ]
  end

  # The get_humanize_id_card_type method is used to get the humanize id card type of the user
  # By iterating over the id card options and comparing the id card type of the user with the id card type of the options
  # If the id card type of the user matches with the id card type of the options, the humanize id card type is returned
  def get_humanize_id_card_type(t = nil)
    t ||= self.id_card_type
    id_card_options = self.get_id_card_types

    id_card_options.each do |id_card_type|
      @id_card_type = id_card_type[0] if id_card_type[1].to_s == t.to_s
    end

    @id_card_type
  end

  # The get_humanize_gender method is used to get the humanize id card type of the user
  # By iterating over the id gender options and comparing the id gender type of the user with the id gender type of the options
  # If the id gender type of the user matches with the id gender type of the options, the humanize id gender type is returned
  def get_humanize_gender(g = nil)
    g ||= self.gender
    gender_options = self.get_gender_options

    gender_options.each do |gender|
      @gender = gender[0] if gender[1].to_s == g.to_s
    end

    @gender
  end

  # The get_humanize_marital_status method is used to get the humanize id card type of the user
  # By iterating over the id marital status options and comparing the id marital status type of the user with the id marital status type of the options
  # If the id marital status type of the user matches with the id marital status type of the options, the humanize id marital status type is returned
  def get_humanize_marital_status(m = nil)
    m ||= self.marital_status
    marital_status_options = self.get_marital_status_options

    marital_status_options.each do |marital_status|
      @marital_status = marital_status[0] if marital_status[1].to_s == m.to_s 
    end

    @marital_status
  end
  
  # The get_humanize_education method is used to get the humanize id card type of the user
  # By iterating over the id education options and comparing the id education type of the user with the id education type of the options
  # If the id education type of the user matches with the id education type of the options, the humanize id education type is returned
  def get_humanize_education(e = nil)
    e ||= self.education
    education_options = self.get_education_options

    education_options.each do |education|
      @education = education[0] if education[1].to_s == e.to_s
    end

    @education
  end

  # The get_short_name method is used to get the short name of the user
  # By splitting the fullname of the user and getting the first and second name
  # If the fullname of the user has more than two words, the short name is the first and second word
  # If the fullname of the user has less than two words, the short name is the first word
  def get_short_name
    fullname = self.fullname.split(" ")
    if fullname.length >= 2
      short_name = fullname[0] + " " + fullname[1]
    else
      short_name = fullname[0]
    end
  end

  # the self.ransackable_attributes method is used to search for attributes of the model
  # It is used to search for the attributes of the user that are allowed to search
  def self.ransackable_attributes(auth_object = nil)
    ["account_number", "address", "birth_date", "canton", "created_at", "district", "education", "email", "fullname", "gender", "id", "id_card", "id_card_type", "job_position", "marital_status", "nationality", "phone", "province", "role", "status", "updated_at"]
  end

  # The clean_changes method is used to clean the changes log table before deleting a user
  # The 'where' method is used to get the changes log of the user and destroy them before deleting the user
  def clean_changes
    ChangeLog.where(table_id: self.id, table_name: "user").destroy_all
  end
  
  # The 'has_many' method is used to define the relationship between the user and the projects
  has_many :projects
  
  # The 'has_many' method is used to define the relationship between the user and the emergency contacts
  # The 'dependent' option is used to delete the emergency contacts of the user when the user is deleted
  # The 'accepts_nested_attributes_for' method is used to accept the nested attributes for the emergency contacts
  # The 'allow_destroy' option is used to allow the destruction of the emergency contacts
  # The 'reject_if' option is used to reject the emergency contacts if the attributes are blank
  has_one :emergency_contact, dependent: :destroy
  accepts_nested_attributes_for :emergency_contact, allow_destroy: true, reject_if: :all_blank

  # The 'has_many' method is used to define the relationship between the user and the activities
  has_many :activities

  # The 'has_many' method is used to define the relationship between the user and the minutes
  # The 'dependent' option is used to delete the minutes of the user when the user is deleted
  # The 'through' option is used to define the relationship between the user and the minutes_users
  has_many :minutes_users, dependent: :destroy
  has_many :minutes, through: :minutes_users

  # The 'has_many' method is used to define the relationship between the user and the assigned_tasks
  #has_many :assigned_tasks

  # The devise method is used to define the devise modules of the model
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable
end
