require "rails_helper"

RSpec.describe "Opt In Messages", type: :system do
  let!(:contact) do
    Contact.create(
      first_name: "Brian",
      phone_number: "5551231234",
      renewal_date: "2019/01/05",
      carrier_type: 'mobile'
    )
  end

  before do
    allow(SmsService).to receive(:send_message)
  end

  it "affirmative opt-in" do
    OptInMessage.send_to_recipients

    expect(SmsService).to have_received(:send_message) do |message|
      expect(message.body).to include "Louisiana Medicaid is testing out a text message reminder program."
      expect(message.message_type).to eq "OptInMessage"
    end

    RSpec::Mocks.space.proxy_for(SmsService).reset
    allow(SmsService).to receive(:send_message)

    incoming_sms(phone_number: contact.phone_number, body: "Yes")

    expect(contact.reload.opted_in).to eq true
    expect(SmsService).to have_received(:send_message) do |message|
      expect(message.to_phone_number).to eq contact.phone_number
      expect(message.body).to include "You have opted in to text messages about your Medicaid case."
      expect(message.message_type).to eq 'OptInMessage'
    end

    inbound_message, _confirmation_message = contact.messages.reload.last(2)
    expect(inbound_message.message_type).to eq nil
    expect(inbound_message.inbound?).to eq true
  end

  it 'negative opt out' do
    OptInMessage.new(contact).send_message

    RSpec::Mocks.space.proxy_for(SmsService).reset
    allow(SmsService).to receive(:send_message)

    incoming_sms(phone_number: contact.phone_number, body: "no")

    expect(contact.reload.opted_in).to eq false
    expect(SmsService).to have_received(:send_message) do |message|
      expect(message.to_phone_number).to eq contact.phone_number
      expect(message.body).to include "You have opted out."
      expect(message.message_type).to eq 'OptInMessage'
    end
  end

  it 'other message' do
    OptInMessage.new(contact).send_message

    RSpec::Mocks.space.proxy_for(SmsService).reset
    allow(SmsService).to receive(:send_message)

    incoming_sms(phone_number: contact.phone_number, body: "other")

    expect(contact.reload.opted_in).to eq nil

    expect(SmsService).to have_received(:send_message) do |message|
      expect(message.to_phone_number).to eq contact.phone_number
      expect(message.body).to include "We're unable to confirm any details about your case over text message."
      expect(message.message_type).to eq 'NoReplyMessage'
    end
  end
end
