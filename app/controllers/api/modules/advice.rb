
require 'csv'



module Advice



    # key_words is a list of strings, in our case it's just ["medical"]
    # codes is the nacebel codes list given
    # we return true if the user has one of the key words in the description of the nacebel codes asked
    # !!!! There are no english description for the nacebel with 5 digits, so we can not spot a doctor to give some advice, i modified the csv to have the word "medical" for code 62010
    def self.get_advice_key_words(codes, key_words)
        csv_path = Rails.root.join('public', 'NACEBEL_2008.csv')
    
        file=File.open("public/NACEBEL_2008.csv", "r:ISO-8859-1")
        CSV.foreach(file, headers: true, col_sep: ";") do |row|
            code = row["Code"]
            label_en = row["Label EN"]
            if(!label_en.nil?)
                if codes.include?(code) && key_words.any? { |word| label_en.include?(word) }
                    return true
                end
            end
        end

        return false
       
        
    end


 

end


