class RenameColumnPhoneInLead < ActiveRecord::Migration[6.1]
  def change
    rename_column :leads, :phone, :phone_number
  end
end
