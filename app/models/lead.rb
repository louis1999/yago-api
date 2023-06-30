class Lead < ApplicationRecord
    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :phone_number, presence: true
    validates :address, presence: true
    validates :first_name, presence: true
    validates :last_name, presence: true
end
