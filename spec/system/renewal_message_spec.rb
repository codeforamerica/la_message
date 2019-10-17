require "rails_helper"

RSpec.describe "Renewal Message", type: :system do
  let!(:contact) do
    Contact.create(
      first_name: "Brian",
      phone_number: "5551231234",
      renewal_date: "2019/01/05",
      list: "nov-renewals",
      carrier_type: "mobile",
      segment: 1,
      opted_in: true
    )
  end

  before do
    allow(SmsService).to receive(:send_message)
  end

  it "sends a Renewal message" do
    RenewalMessage.send_to_recipients

    expect(SmsService).to have_received(:send_message) do |message|
      expect(message.to_phone_number).to eq contact.phone_number
      expect(message.body).to include "It's time to renew your household's Medicaid coverage."
      expect(message.body).to include "January 5"
      expect(message.message_type).to eq "RenewalMessage"
    end
  end
end
