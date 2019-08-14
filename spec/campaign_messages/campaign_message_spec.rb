require 'rails_helper'

RSpec.describe CampaignMessage do
  describe '.all_message_classes' do
    it 'includes all descendants' do
      expect(CampaignMessage.all_message_classes).to contain_exactly(
                                                       EnrollmentDocumentsMessage,
                                                       NoReplyMessage,
                                                       OptInMessage,
                                                       RenewalMessage
                                                     )
    end
  end
end
