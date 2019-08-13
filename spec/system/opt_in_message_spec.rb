require "rails_helper"

RSpec.describe "Opt In Messages", type: :system do
  include ActiveSupport::Testing::TimeHelpers

  let(:twilio_client) { instance_double(Twilio::REST::Client, messages: twilio_messages) }
  let(:twilio_messages) { instance_double(Twilio::REST::Api::V2010::AccountContext::MessageList, create: twilio_response) }

  before do
    allow(Twilio::REST::Client).to receive(:new).and_return(twilio_client)
  end

  it "affirmative opt-in" do
    contact = Contact.create(
      first_name: "Brian",
      phone_number: "5551231234",
      renewal_date: "2019/01/05",
      carrier_type: 'mobile'
    )

    OptInMessage.send_to_recipients

    expect(twilio_messages).to have_received(:create) do |args|
      expect(args[:body]).to include "Louisiana Medicaid is testing out a text message reminder program."
    end
    expect(contact.messages.reload.last.message_type).to eq "OptInMessage"

    RSpec::Mocks.space.proxy_for(twilio_messages).reset
    allow(twilio_messages).to receive(:create).and_return(twilio_response)

    # they affirmatively say yes
    incoming_sms(phone_number: contact.phone_number, body: "Yes")

    expect(contact.reload.opted_in).to eq true
    expect(twilio_messages).to have_received(:create) do |args|
      expect(args[:body]).to include "You have opted in to text messages about your Medicaid case."
    end

    inbound_message, confirmation_message = contact.messages.reload.last(2)
    expect(inbound_message.message_type).to eq nil
    expect(inbound_message.inbound?).to eq true

    expect(confirmation_message.message_type).to eq "OptInMessage"
  end

  it 'negative opt out' do
    contact = Contact.create(
      first_name: "Nate",
      phone_number: "5551231234",
      renewal_date: "2019/01/15"
    )

    OptInMessage.new(contact).send_message

    RSpec::Mocks.space.proxy_for(twilio_messages).reset
    allow(twilio_messages).to receive(:create).and_return(twilio_response)

    incoming_sms(phone_number: contact.phone_number, body: "no")

    expect(contact.reload.opted_in).to eq false
    expect(twilio_messages).to have_received(:create) do |args|
      expect(args[:body]).to include "You have opted out."
    end
  end
end
