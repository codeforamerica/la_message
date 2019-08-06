require "rails_helper"

RSpec.describe "Renewal Message", type: :system do
  include ActiveSupport::Testing::TimeHelpers

  let(:twilio_client) { instance_double(Twilio::REST::Client, messages: twilio_messages) }
  let(:twilio_messages) { instance_double(Twilio::REST::Api::V2010::AccountContext::MessageList, create: twilio_response) }

  before do
    allow(Twilio::REST::Client).to receive(:new).and_return(twilio_client)
  end

  describe

  it "sends a Renewal Notice with date" do
    contact = Contact.create(
      first_name: "Brian",
      phone_number: "5551231234",
      renewal_date: "2019/01/05",
      opted_in: true
    )

    RenewalNoticeMessage.send_to_recipients

    expect(twilio_messages).to have_received(:create) do |args|
      expect(args[:body]).to include "It's time to renew your household's Medicaid coverage."
      expect(args[:body]).to include "January 5"
    end
    expect(contact.messages.reload.last.message_type).to eq "RenewalNoticeMessage"
  end
end
