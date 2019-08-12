require 'rails_helper'

RSpec.describe Contact, type: :model do
  describe '#phone_number=' do
    it 'formats the phone number with a +1' do
      contact = Contact.new phone_number: '555-555-5555'
      expect(contact.phone_number).to eq '+15555555555'
    end
  end

  describe '.received_message and .not_received_message' do
    let!(:contact_received_alpha) do
      Contact.create!.tap do |c|
        Message.create!(contact: c, message_type: nil)
        Message.create!(contact: c, message_type: 'AlphaMessage')
      end
    end
    let!(:contact_received_alpha_beta) do
      Contact.create!.tap do |c|
        Message.create!(contact: c, message_type: 'AlphaMessage')
        Message.create!(contact: c, message_type: nil)
        Message.create!(contact: c, message_type: 'BetaMessage')
      end
    end

    before do
      stub_const('AlphaMessage', Class.new(CampaignMessage))
      stub_const('BetaMessage', Class.new(CampaignMessage))
    end

    describe '.received_message' do
      it 'includes contacts that received the message' do
        expect(described_class.received_message(AlphaMessage)).to contain_exactly(contact_received_alpha, contact_received_alpha_beta)
        expect(described_class.received_message(BetaMessage)).to contain_exactly(contact_received_alpha_beta)
      end
    end

    describe '.not_received_message' do
      it 'excludes contacts that received the message' do
        expect(described_class.not_received_message(AlphaMessage)).to be_empty
        expect(described_class.not_received_message(BetaMessage)).to contain_exactly(contact_received_alpha)
      end
    end
  end
end
