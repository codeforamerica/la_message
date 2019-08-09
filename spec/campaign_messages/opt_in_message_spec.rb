require 'rails_helper'

RSpec.describe OptInMessage do
  describe '.recipients' do
    let!(:contact_nil_opt) { Contact.create! opted_in: nil }
    let!(:contact_false_opt) { Contact.create! opted_in: false }
    let!(:contact_received_message) do
      Contact.create!.tap do |c|
        Message.create!(contact: c, message_type: described_class.name)
        Message.create!(contact: c, message_type: nil)
        Message.create!(contact: c, message_type: 'SomeMessage')
      end
    end

    it 'only sends to contacts who have nil and have not received the message' do
      expect(described_class.recipients.to_a).to contain_exactly(contact_nil_opt)
    end
  end

  describe '#on_reply' do
    let!(:contact) { Contact.create! opted_in: nil }

    before do
      allow(SmsService).to receive(:send_message)
    end

    context 'affirmative response' do
      it 'sends a response message' do
        reply_message = Message.new(contact: contact, body: 'yes')
        described_class.new(contact).on_reply(reply_message)

        expect(SmsService).to have_received(:send_message) do |message|
          expect(message.body).to include "You have opted in"
        end
      end

      ["yes", "y", " y ", "Yes!", "and yes"].each do |body|
        it "reply of '#{body}' updates contact opt in as true" do
          message = Message.new(contact: contact, body: body)
          described_class.new(contact).on_reply(message)
          expect(contact.opted_in).to eq true
        end
      end
    end

    context 'negative response' do
      it 'sends a response message' do
        reply_message = Message.new(contact: contact, body: 'no')
        described_class.new(contact).on_reply(reply_message)

        expect(SmsService).to have_received(:send_message) do |message|
          expect(message.body).to include "You have opted out"
        end
      end

      ["no", "n", " n ", "No!", "and no"].each do |body|
        it "reply of '#{body}' updates contact opt in as false" do
          message = Message.new(contact: contact, body: body)
          described_class.new(contact).on_reply(message)
          expect(contact.opted_in).to eq false
        end
      end
    end
  end
end
