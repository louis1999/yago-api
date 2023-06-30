require 'httparty'
require_relative "../../modules/advice"



module Api
    module V1
        class QuotesController < ApplicationController

            include Module::Advice

            # here is the list where each keyword has a list of associated recommendations
            # it is not perfectly relevent since the keywords manual and consultant do not exist but the idea is there
            @@advice_dictionary = {
                "medical" => ["Recommended deductible formula is small.", "Recommended coverage ceiling formula is large.", "Legal expense cover is strongly recommended."],
                "manual" => ["Recommended deductible formula is small.", "Entrusted objects cover is strongly recommended."],
                "consultant" => ["Recommended deductible formula is medium.", "After delivery cover is strongly recommended."]
              }



            # called by the client to receive a quote
            # the action calls the insurance api to get a quote
            # the quote is stored in database in case the user wants to get it by email
            # To improve that action, we can do some validations on the params (eg check that the enums are correct)
            # another improvement: the nace bel numbers must contain 5 digits and be in the nacebel list
            # TODO : for the advice, check the nacebel number in the list, check the description, if "medical" is in it, return advices
            def create
                if valid_params?(quote_params)
                    payload = {
                        annualRevenue: quote_params[:annualRevenue],
                        enterpriseNumber: quote_params[:enterpriseNumber],
                        legalName: quote_params[:legalName],
                        naturalPerson: quote_params[:naturalPerson],
                        nacebelCodes: quote_params[:nacebelCodes],
                        deductibleFormula: quote_params[:deductibleFormula],
                        coverageCeilingFormula: quote_params[:coverageCeilingFormula]
                    }
    
                    response = HTTParty.post('https://staging-gtw.seraphin.be/quotes/professional-liability',
                        headers: {
                        'X-Api-Key': ENV['API_KEY'],
                        'Content-Type': 'application/json'
                        },
                        body: payload.to_json
                    )
    
                    if response.code == 200
                        json_data = response.parsed_response["data"]
    

                        new_quote = {
                            available: json_data["available"],
                            coverage_ceiling: json_data["coverageCeiling"],
                            deductible: json_data["deductible"],
                            insurance_quote_id: json_data["quoteId"],
                            after_delivery: json_data["grossPremiums"]["afterDelivery"],
                            public_liability: json_data["grossPremiums"]["publicLiability"],
                            professional_indemnity: json_data["grossPremiums"]["professionalIndemnity"],
                            entrusted_objects: json_data["grossPremiums"]["entrustedObjects"],
                            legal_expenses: json_data["grossPremiums"]["legalExpenses"]
                          }
        
                         
                        quote = Quote.new(new_quote)
                        if quote.save
                            quote_data = {
                                quote_id: quote.insurance_quote_id,
                                available: quote.available,
                                coverage_ceiling: quote.coverage_ceiling,
                                deductible: quote.deductible,
                                coverPremiums:{
                                    after_delivery: quote.after_delivery,
                                    public_liability: quote.public_liability,
                                    professional_indemnity: quote.professional_indemnity,
                                    entrusted_objects: quote.entrusted_objects,
                                    legal_expenses: quote.legal_expenses,
                                }
                              }
                            
                            advice_data=[]
                            medical_advice = Advice.get_advice_key_words(quote_params[:nacebelCodes], ["medical"])
                            if medical_advice
                                advice_data = advice_data+ @@advice_dictionary["medical"]
                            end


                            render json: {quote: quote_data, covers_advice: advice_data}, status: :created
                        else
                            render json: quote.errors, status: :unprocessable_entity
                        end
                    else
                        render json: { error: 'Failed to create quote' }, status: :unprocessable_entity
                    end
                else
                    render json: { error: 'Failed to create quote, parameters not valid' }, status: :unprocessable_entity
                end
                
            end


            private

    
            def quote_params
                params.require(:quote).permit(:annualRevenue, :enterpriseNumber, :legalName, :naturalPerson, :deductibleFormula, :coverageCeilingFormula, nacebelCodes: []) 
            end

            # verify that all the params are valid
            def valid_params?(params)
                return valid_enterprise_number?(params[:enterpriseNumber]) && valide_nacebel_codes?(params[:nacebelCodes])
            end

            def valid_enterprise_number?(enterprise_number)
                enterprise_number.to_s.start_with?('0') && enterprise_number.to_s.length == 10
            end

            # TODO : here we could also check if the 5 digits code is a real nacebel code belonging to the list in the csv
            def valide_nacebel_codes?(nacebel_codes)
                nacebel_codes.all? { |code| code.to_s.match?(/\A\d{5}\z/) }
            end

        end
    end
end


