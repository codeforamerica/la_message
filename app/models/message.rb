# == Schema Information
#
# Table name: messages
#
#  id                :bigint           not null, primary key
#  body              :text
#  error_code        :integer
#  error_message     :text
#  from_phone_number :text
#  message_type      :text
#  outbound          :boolean
#  status            :text
#  to_phone_number   :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  contact_id        :bigint
#  twilio_id         :text
#
# Indexes
#
#  index_messages_on_contact_id  (contact_id)
#  index_messages_on_twilio_id   (twilio_id) UNIQUE
#

class Message < ApplicationRecord
  belongs_to :contact, optional: true

  scope :outbound, -> { where(outbound: true) }
  scope :inbound, -> { where(outbound: false) }
  scope :with_type, ->(message_class) { where(message_type: message_class.name) }

  def inbound?
    !outbound? unless outbound.nil?
  end

  def inbound=(value)
    self.outbound = !value
  end
end
