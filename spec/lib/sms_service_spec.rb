require 'rails_helper'

RSpec.describe SmsService do
  let(:twilio_client) { instance_double(Twilio::REST::Client, messages: twilio_messages) }
  let(:twilio_response) { OpenStruct.new(sid: "12345") }
  let(:twilio_messages) { instance_double(Twilio::REST::Api::V2010::AccountContext::MessageList, create: twilio_response) }

  before do
    allow(Twilio::REST::Client).to receive(:new).and_return(twilio_client)
  end

  around do |example|
    with_modified_env(TWILIO_MESSAGE_SERVICE: 'MS12345') { example.run }
  end

  describe '.send_message' do
    it 'sends the message body to the correct phone number' do
      message = Message.create to_phone_number: "+12223334444", body: 'hello'

      SmsService.send_message(message)

      expect(twilio_messages).to have_received(:create) do |args|
        expect(args[:messaging_service_sid]).to eq "MS12345"
        expect(args[:to]).to eq message.to_phone_number
        expect(args[:body]).to eq message.body
      end
    end

    it 'saves the message id' do
      message = Message.create to_phone_number: "+12223334444", body: 'hello'

      SmsService.send_message(message)

      expect(message.reload.twilio_id).to eq twilio_response.sid
    end
  end

  describe '.send_sms' do
    it 'sends a bare message' do
      SmsService.send_sms(to: "+12223334444", body: 'hello')

      expect(twilio_messages).to have_received(:create) do |args|
        expect(args[:messaging_service_sid]).to eq "MS12345"
        expect(args[:to]).to eq "+12223334444"
        expect(args[:body]).to eq 'hello'
      end
    end
  end
end
