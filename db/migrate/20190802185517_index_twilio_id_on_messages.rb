class IndexTwilioIdOnMessages < ActiveRecord::Migration[5.2]
  def change
    add_index :messages, :twilio_id, unique: true
  end
end
