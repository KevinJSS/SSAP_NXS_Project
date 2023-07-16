class EmergencyContact < ApplicationRecord
    # The 'before_save' callback is used to set the fullname attribute to uppercase before saving the emergency contact
    before_save { self.fullname = fullname.upcase }

    # The 'before_save' callback is used to trim the values of the fullname and phone attributes before saving the emergency contact
    before_save :trim_values

    # The 'validates' method is used to validate the attributes of the model
    # The 'presence' option is used to validate that the attribute is not empty
    # The 'length' option is used to validate the length of the attribute
    validates :fullname, presence: true, length: { in: 5..100 }
    validates :phone, presence: true, length: { in: 8..20 }

    # The 'trim_values' method is used to trim the values of the fullname and phone attributes before saving the emergency contact
    def trim_values
        self.fullname = fullname.strip if fullname.present?
        self.phone = phone.strip if phone.present?
    end

    # The belongs_to method is used to define the relationship between the emergency contact and the user
    # An emergency contact belongs to a user 
    belongs_to :user
end
