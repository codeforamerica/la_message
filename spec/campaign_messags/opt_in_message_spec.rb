require 'rails_helper'

RSpec.describe OptInMessage do
  describe '.recipients' do
    let!(:contact_nil_opt) { Contact.create! opted_in: nil }
    let!(:contact_false_opt) { Contact.create! opted_in: false }
    let!(:contact_received_message) { Contact.create!.tap { |c| Message.create! contact: c, message_type: described_class.name; Message.create! contact: c, message_type: nil;  Message.create! contact: c, message_type: 'SomeMessage'} }

    it 'only sends to contacts who have nil and have not received the message' do
      expect(described_class.recipients.to_a).to contain_exactly(contact_nil_opt)
    end
  end
end
