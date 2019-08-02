require 'rails_helper'

RSpec.describe Twilio::IncomingsController do
  describe '#create' do
    it 'creates a new message' do
      expect do
        post twilio_incoming_path, params: {
          "Body": "hello",
          "To": "+15555555555",
          "From": "+16666666666",
          "MessageSid": "SM12345",
        }
      end.to change(Message, :count).by(1)
    end

    context 'when there is an expected reply' do
      class TestReplyMessage
        def initialize(contact)
        end

        def on_reply(message)
        end
      end

      let(:contact) { Contact.create first_name: 'test', phone_number: '16666666666' }
      let(:test_reply_message) { instance_double TestReplyMessage, on_reply: nil }

      before do
        allow(TestReplyMessage).to receive(:new).and_return(test_reply_message)
        Message.create contact: contact, outbound: true, message_type: 'TestReplyMessage'
      end

      it 'calls the reply callback with a newly created message' do
        post twilio_incoming_path, params: {
          "Body": "hello",
          "To": "+15555555555",
          "From": contact.phone_number,
          "MessageSid": "SM12345",
        }

        expect(test_reply_message).to have_received(:on_reply) do |message|
          expect(message.contact).to eq contact
          expect(message.body).to eq "hello"
          expect(message.from_phone_number).to eq contact.phone_number
          expect(message.twilio_id).to eq "SM12345"
        end
      end
    end
  end
end
