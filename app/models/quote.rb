class Quote < ApplicationRecord

  


    # insurance_quote_id is the quote_id given by the insurance

    validates :insurance_quote_id, presence: true, uniqueness: true
  

  end
  