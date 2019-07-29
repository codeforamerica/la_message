require "rails_helper"

RSpec.describe "Campaign", type: :system do
  include ActiveSupport::Testing::TimeHelpers

  let(:twilio_client) { double(Twilio::REST::Client, messages: twilio_messages) }
  let(:twilio_messages) { double(Twilio::REST::ListResource, create: twilio_response) }
  let(:twilio_response) { OpenStruct.new(sid: 'SM123') }

  before do
    allow(Twilio::REST::Client).to receive(:new).and_return(twilio_client)
  end

  it "affirmative opt-in and campaign" do
    contact = Contact.create(
      name: "Brian",
      phone_number: "5551231234",
      renewal_date: "2019/01/15"
    )

    # send them an opt-in message
    CampaignMessage.send_all

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

    (1..9).each do |day|
      travel day.days + 1.hour do
        RSpec::Mocks.space.proxy_for(twilio_messages).reset
        allow(twilio_messages).to receive(:create).and_return(twilio_response)

        CampaignMessage.send_all

        expect(twilio_messages).not_to have_received(:create)
      end
    end

    travel 10.days + 1.hour do
      RSpec::Mocks.space.proxy_for(twilio_messages).reset
      allow(twilio_messages).to receive(:create).and_return(twilio_response)

      CampaignMessage.send_all

      expect(twilio_messages).to have_received(:create) do |args|
        expect(args[:body]).to include "It is time to renew your household's Medicaid coverage."
      end
      expect(contact.messages.reload.last.message_type).to eq "RenewalNoticeMessage"
    end

    RSpec::Mocks.space.proxy_for(SmsService).reset
    (11..19).each do |day|
      travel day.days + 1.hour do
        RSpec::Mocks.space.proxy_for(twilio_messages).reset
        allow(twilio_messages).to receive(:create).and_return(twilio_response)

        CampaignMessage.send_all

        expect(twilio_messages).not_to have_received(:create)
      end
    end

    travel 20.days + 1.hour do
      RSpec::Mocks.space.proxy_for(twilio_messages).reset
      allow(twilio_messages).to receive(:create).and_return(twilio_response)

      CampaignMessage.send_all

      expect(twilio_messages).to have_received(:create) do |args|
        expect(args[:body]).to include "To complete your Medicaid renewal, please submit the following documents by"
      end
      expect(contact.messages.reload.last.message_type).to eq "ListOfDocumentsMessage"
    end
  end

  def incoming_sms(phone_number:, body:)
    post twilio_incoming_url, params: {
      "Body": body,
      "To": "+15555555555",
      "From": "+1#{phone_number}",
    }
  end
end
