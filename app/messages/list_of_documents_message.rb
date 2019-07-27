class ListOfDocumentsMessage
  attr_reader :contact

  def self.send_to_contacts
    Contact.where("created_at < ?", 20.days.ago).find_each do |contact|
      new(contact).send_message
    end
  end

  def initialize(contact)
    @contact = contact
  end

  def send_message
    message = "Louisiana Medicaid is testing out a text message reminder program. "\
              "Would you like to receive reminders, notices and confirmations about the enrollment and renewal processes? "\
              "These texts will b in addition to any letters and calls you already receive. "\
              "Please reply with YES or NO. You can opt out of the service at any time."

    SmsService.send_message(
      phone_number: contact.phone_number,
      message: message
    )

    contact.messages.create(
      message_type: self.class.name,
      to_phone_number: contact.phone_number,
      body: message,
    )
  end
end
