class Message < ApplicationRecord
  belongs_to :contact

  def inbound?
    !outbound? unless outbound.nil?
  end

  def inbound=(value)
    self.outbound = !value
  end
end
