class CampaignMessage
  attr_reader :campaign

  def self.recipients
    raise 'Not Implemented'
  end

  def self.all_message_classes
    ::CampaignMessage.descendants
  end

  def self.send_to_recipients
    recipients.find_each do |contact|
      new(contact).send_message
    end
  end

  def initialize(contact)
    @contact = contact
  end

  def on_reply(message)
  end
end
