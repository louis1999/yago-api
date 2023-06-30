module Api
    module V1
        class LeadsController < ApplicationController


            # create lead and link that lead to the quote he just received
            def create

                # remove the quote_id 
                lead_parameter = lead_params.slice("email", "phone_number", "address", "first_name", "last_name")


                lead = Lead.new(lead_parameter)
                # todo, i need insurance quote id in the params to update the quote
            
                if lead.save
                    quote = Quote.find_by(insurance_quote_id: lead_params[:quote_id])

                    if quote.nil?
                        render json: { errors: "Quote not found" }, status: :unprocessable_entity
                      else
                        quote.update(lead_id: lead.id)
                        # Improvement
                        # send the quote and the list of advice by email to the new lead
                        render json: { message: "Lead created successfully" }, status: :created
                      end
                else
                    # Lead validation failed
                    render json: { errors: lead.errors.full_messages }, status: :unprocessable_entity
                end
            end




            private

            def lead_params
                params.require(:lead).permit(:email, :phone_number, :address, :first_name, :last_name, :quote_id)
            end

        end
    end
end
