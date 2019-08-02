require 'rails_helper'

RSpec.describe PhoneNumber do
  describe '#format' do
    it 'adds a +1 to the front of a 10-digit number' do
      expect(PhoneNumber.format('5555555555')).to eq '+15555555555'
    end

    it 'adds a + in front of an 11-digit number' do
      expect(PhoneNumber.format('15555555555')).to eq '+15555555555'
    end
  end
end
