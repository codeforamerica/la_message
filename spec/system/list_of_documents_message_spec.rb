require "rails_helper"

RSpec.describe "List of Documents Message spec Message", type: :system do
  include ActiveSupport::Testing::TimeHelpers

  let(:twilio_client) { instance_double(Twilio::REST::Client, messages: twilio_messages) }
  let(:twilio_messages) { instance_double(Twilio::REST::Api::V2010::AccountContext::MessageList, create: twilio_response) }

  before do
    allow(Twilio::REST::Client).to receive(:new).and_return(twilio_client)
  end

  it "sends a List of Documents message" do
    Contact.create(
      first_name: "Brian",
      phone_number: "5551231234",
      renewal_date: "2019/01/05",
      opted_in: true
    )

    ListOfDocumentsMessage.send_to_recipients

    expect(twilio_messages).to have_received(:create) do |args|
      expect(args[:body]).to include "To complete your Medicaid renewal, please submit the following documents by"
    end
  end
end