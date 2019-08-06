# == Schema Information
#
# Table name: contacts
#
#  id           :bigint           not null, primary key
#  carrier_type :text
#  first_name   :text
#  last_name    :text
#  opted_in     :boolean
#  phone_number :text
#  renewal_date :date
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Contact < ApplicationRecord
  has_many :messages, -> { order(created_at: :asc) }

  scope :opted_in, -> { where(opted_in: true) }
  scope :received_message, ->(message_class) { joins(:messages).where(messages: { message_type: message_class.name }).distinct }
  scope :not_received_message, ->(message_class) { where.not(id: received_message(message_class).select(:id)) }

  def phone_number=(value)
    super(PhoneNumber.format(value))
  end
end
