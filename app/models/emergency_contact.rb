class EmergencyContact < ApplicationRecord
    #validations
    before_save { self.fullname = fullname.upcase }
    before_save :trim_values

    validates :fullname, presence: true, length: { in: 5..100 }
    validates :phone, presence: true, length: { in: 8..20 }

    def trim_values
        self.fullname = fullname.strip if fullname.present?
        self.phone = phone.strip if phone.present?
    end

    #associations 
    belongs_to :user
end
