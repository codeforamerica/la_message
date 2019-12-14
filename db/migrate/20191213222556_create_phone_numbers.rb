class CreatePhoneNumber < ActiveRecord::Migration[5.2]
  def change
    create_table :phone_numbers do |t|
      t.string :phone_number
      t.string :wic_id
      t.string :snap_id
      t.string :tanf_id
      t.string :medicaid_id
      t.string :first_name
      t.string :last_name
      t.integer :sms_deliverable, default: 0
      t.boolean :opt_in, default: false
    end
  end
end
