require 'rails_helper'

RSpec.describe Contact, type: :model do
  describe '#phone_number' do
    it 'formats the phone number with a +1' do
      contact = Contact.new phone_number: '555-555-5555'
      expect(contact.phone_number).to eq '+15555555555'
    end
  end
end
