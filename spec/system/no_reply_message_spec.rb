require "rails_helper"

RSpec.describe "No reply message", type: :system do
  include ActiveSupport::Testing::TimeHelpers

  let!(:contact) do
    Contact.create(
      first_name: "Brian",
      phone_number: "5551231234",
      renewal_date: "2019/01/05",
      carrier_type: 'mobile',
      segment: 1
    )
  end

  before do
    allow(SmsService).to receive(:send_message)
  end

  it "sends a reply only once when someone texts in" do
    incoming_sms(phone_number: contact.phone_number, body: "Ask for help.")

    expect(SmsService).to have_received(:send_message) do |message|
      expect(message.to_phone_number).to eq contact.phone_number
      expect(message.body).to include "We're unable to confirm any details about your case over text message."
      expect(message.message_type).to eq 'NoReplyMessage'
    end
  end

  it 'only replies once a day' do
    incoming_sms(phone_number: contact.phone_number, body: "Ask for help.")
    incoming_sms(phone_number: contact.phone_number, body: "Another help")
    incoming_sms(phone_number: contact.phone_number, body: "Another help")

    expect(SmsService).to have_received(:send_message).once

    travel 1.5.days do
      incoming_sms(phone_number: contact.phone_number, body: "Ask for help later.")

      expect(SmsService).to have_received(:send_message).twice
    end
  end

  context 'When they have recieved multiple campaign messages' do
    it "uses the latest on_reply" do
      OptInMessage.new(contact).send_message

      incoming_sms(phone_number: contact.phone_number, body: "Yes")

      EnrollmentDocumentsMessage.new(contact).send_message

      incoming_sms(phone_number: contact.phone_number, body: "No I cannot send those documents")

      expect(contact.reload.opted_in).to eq true
    end
  end
end
