class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.timestamps

      t.references :contact
      t.text :to_phone_number
      t.text :from_phone_number
      t.text :body
      t.text :message_type
      t.boolean :outbound
      t.text :twilio_id
    end
  end
end
