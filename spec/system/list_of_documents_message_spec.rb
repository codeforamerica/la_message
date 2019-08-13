require "rails_helper"

RSpec.describe "List of Documents Message spec Message", type: :system do
  let!(:contact) do
    Contact.create(
      first_name: "Brian",
      phone_number: "5551231234",
      documents_due_date: "2019/01/15",
      documents: ["Document 1", "Document 2"],
      opted_in: true
    )
  end

  before do
    allow(SmsService).to receive(:send_message)
  end

  it "sends a List of Documents message" do
    ListOfDocumentsMessage.send_to_recipients

    expect(SmsService).to have_received(:send_message) do |message|
      expect(message.body).to include "To complete your Medicaid renewal, please submit the following documents by"
      expect(message.body).to include "January 15"
      expect(message.body).to include "* Document 1\n* Document 2"
    end
  end
end
