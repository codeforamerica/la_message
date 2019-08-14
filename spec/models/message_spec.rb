require 'rails_helper'

RSpec.describe Message, type: :model do
  describe '#inbound=' do
    it 'sets outbound to the opposite' do
      message = Message.new
      expect do
        message.inbound = true
      end.to change(message, :outbound).from(nil).to false

      message = Message.new
      expect do
        message.inbound = false
      end.to change(message, :outbound).from(nil).to true

      message = Message.new
      expect do
        message.inbound = nil
      end.not_to change(message, :outbound).from(nil)
    end
  end

  describe '#message_type' do
    it 'coerces temporary values' do
      message = Message.create message_type: 'RenewalNoticeMessage'
      expect(message.message_type).to eq 'RenewalMessage'

      message = Message.create message_type: 'ListOfDocumentsMessage'
      expect(message.message_type).to eq 'EnrollmentDocumentsMessage'
    end
  end
end
