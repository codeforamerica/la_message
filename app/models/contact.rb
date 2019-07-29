class Contact < ApplicationRecord
  has_many :messages, -> { order(created_at: :asc) }

  scope :opted_in, -> { where(opted_in: true) }
  scope :received_message, -> (message_class) { joins(:messages).where(messages: { message_type: message_class.name }).distinct }
  scope :not_received_message, -> (message_class) { where.not(id: received_message(message_class).select(:id)) }
end
