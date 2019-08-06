require 'rails_helper'

RSpec.describe Twilio::StatusesController do
  describe '#create' do
    it 'updates the message' do
      message = Message.create! to_phone_number: '+15555555555', twilio_id: "SM12345"

      post twilio_status_path, params: {
        "SmsStatus": "delivered",
        "MessageStatus": "delivered",
        "To": "+15555555555",
        "MessageSid": "SM12345",
        "From": "+6666666666",
      }

      message.reload

      expect(message.status).to eq 'delivered'
      expect(message.from_phone_number).to eq "+6666666666"
    end
  end
end
