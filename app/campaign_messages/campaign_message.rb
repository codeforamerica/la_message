class CampaignMessage
  def self.recipients
    raise 'Not Implemented'
  end

  def self.all_message_classes
    ::CampaignMessage.descendants
  end

  def self.send_all
    all_message_classes.each { |message_class| message_class.send_to_contacts }
  end

  def self.send_to_contacts
    recipients.find_each do |contact|
      new(contact).send_message
    end
  end
end
