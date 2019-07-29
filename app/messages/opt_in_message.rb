class OptInMessage
  attr_reader :contact

  def self.send_to_contacts
    Contact.where(opted_in: nil).find_each do |contact|
      new(contact).send_message
    end
  end

  def initialize(contact)
    @contact = contact
  end

  def send_message
    body = "Louisiana Medicaid is testing out a text message reminder program. "\
           "Would you like to receive reminders, notices and confirmations about the enrollment and renewal processes? "\
           "These texts will be in addition to any letters and calls you already receive. "\
           "Please reply with YES or NO. You can opt out of the service at any time."

    message = contact.messages.create!(
      message_type: self.class.name,
      to_phone_number: contact.phone_number,
      body: body
    )

    SmsService.send_message(message)
  end

  def on_reply(message)
    clean_reply = message.body.downcase.strip

    if clean_reply.match Regexp.union([/\Ay\z/, /yes/i])
      contact.update opted_in: true

      body = "You have opted in to text messages about your Medicaid case. "\
                "You can opt out of this service at any time by replying with STOP."

      message = contact.messages.create!(
        message_type: self.class.name,
        to_phone_number: contact.phone_number,
        body: body
      )

      SmsService.send_message(message)
    elsif clean_reply.match Regexp.union([/\An\z/, /no/i])
    end
  end
end
