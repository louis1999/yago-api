class CreateLeadsAndQuotes < ActiveRecord::Migration[6.1]
  def change
    create_table :leads do |t|
      t.string :email
      t.string :phone_number
      t.string :address
      t.string :first_name
      t.string :last_name
      t.timestamps null: false
    end

    create_table :quotes do |t|
      t.references :lead, foreign_key: true, null: true
      t.boolean :available, default: true
      t.integer :coverage_ceiling
      t.integer :deductible
      t.string :insurance_quote_id
      t.float :after_delivery
      t.float :public_liability
      t.float :professional_indemnity
      t.float :entrusted_objects
      t.float :legal_expenses
      t.timestamps null: false
    end
  end
end
