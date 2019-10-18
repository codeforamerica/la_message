require "rails_helper"

RSpec.describe "EnrollmentDocumentsMessage", type: :system do
  let!(:contact) do
    Contact.create(
      first_name: "Brian",
      phone_number: "5551231234",
      enrollment_documents: ["Document 1", "Document 2"],
      segment: 1,
      list: "oct-apps",
      carrier_type: 'mobile',
      opted_in: true
    )
  end

  before do
    allow(SmsService).to receive(:send_message)
  end

  it "sends a message" do
    EnrollmentDocumentsMessage.send_to_recipients

    expect(SmsService).to have_received(:send_message) do |message|
      expect(message.body).to include "To complete your Medicaid application, please submit the following documents soon"
      expect(message.body).to include "* Document 1\n* Document 2"
      expect(message.message_type).to eq "EnrollmentDocumentsMessage"
    end
  end
end
