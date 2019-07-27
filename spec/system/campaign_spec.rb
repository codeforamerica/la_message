require "rails_helper"

RSpec.describe "Campaign", type: :system do
  include ActiveSupport::Testing::TimeHelpers

  it "affirmative opt-in and campaign" do
    contact = Contact.create(
      name: "Brian",
      phone_number: "5551231234",
      renewal_date: "2019/01/15"
    )

    # send them an opt-in message
    allow(SmsService).to receive(:send_message)
    OptInMessage.send_to_contacts
    # verify that message is sent
    expect(SmsService).to have_received(:send_message).with(phone_number: contact.phone_number, message: a_string_including("Louisiana Medicaid is testing out a text message reminder program."))
    expect(contact.messages.reload.last.message_type).to eq "OptInMessage"

    # they affirmatively say yes
    OptInMessage.new(contact).on_reply("Yes")
    expect(contact.reload.opted_in).to eq true
    expect(contact.messages.reload.last.message_type).to eq nil
    expect(contact.messages.reload.last.inbound?).to eq true

    RSpec::Mocks.space.proxy_for(SmsService).reset
    (1..9).each do |day|
      travel day.days + 1.hour do
        allow(SmsService).to receive(:send_message)
        RenewalNoticeMessage.send_to_contacts
        expect(SmsService).not_to have_received(:send_message)

        RSpec::Mocks.space.proxy_for(SmsService).reset
      end
    end

    travel 10.days + 1.hour do
      allow(SmsService).to receive(:send_message)
      RenewalNoticeMessage.send_to_contacts
      expect(SmsService).to have_received(:send_message)

      expect(contact.messages.reload.last.message_type).to eq "RenewalNoticeMessage"
    end

    RSpec::Mocks.space.proxy_for(SmsService).reset
    (11..19).each do |day|
      travel day.days + 1.hour do
        allow(SmsService).to receive(:send_message)
        ListOfDocumentsMessage.send_to_contacts
        expect(SmsService).not_to have_received(:send_message)

        RSpec::Mocks.space.proxy_for(SmsService).reset
      end
    end

    travel 20.days + 1.hour do
      allow(SmsService).to receive(:send_message)
      ListOfDocumentsMessage.send_to_contacts
      expect(SmsService).to have_received(:send_message)

      expect(contact.messages.reload.last.message_type).to eq "ListOfDocumentsMessage"
    end
  end
end
