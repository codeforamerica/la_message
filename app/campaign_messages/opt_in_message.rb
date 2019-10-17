class OptInMessage < CampaignMessage
  def self.recipients
    Contact.where(opted_in: nil).mobile.not_received_message(self)
  end

  def send_message
    return if contact.segment.nil?

    body = if (1..4).include?(contact.segment)
             "Louisiana Medicaid is testing out a text message reminder program. "\
             "Would you like to receive reminders, notices and confirmations about the enrollment and renewal processes? "\
             "These texts will be in addition to any letters and calls you already receive. "\
             "Please reply with YES or NO. You can opt out of the service at any time."
           elsif (5..8).include?(contact.segment)
             "Would you like Louisiana Medicaid to send you reminders about the enrollment and renewal processes? "\
             "These texts will be in addition to any letters and calls you already receive. "\
             "Please reply with YES or NO. You can opt out of the service at any time."
           else
             "Would you like to get text messages from Louisiana Medicaid? "\
             "We’ll send you important reminders about your case. "\
             "These texts will be in addition to any letters and calls you already receive. "\
             "Please reply with YES or NO. You can opt out of the service at any time."
           end

    message = contact.messages.create!(
      message_type: self.class.name,
      to_phone_number: contact.phone_number,
      body: body,
      outbound: true
    )

    SmsService.send_message(message)
  end

  def on_reply(reply_message)
    clean_reply = reply_message.body.downcase.strip

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
      contact.update opted_in: false

      body = "You have opted out. You will not receive any more text messages from Medicaid."

      message = contact.messages.create!(
        message_type: self.class.name,
        to_phone_number: contact.phone_number,
        body: body,
        outbound: true
      )

      SmsService.send_message(message)
    else
      NoReplyMessage.new(contact).on_reply(reply_message)
    end
  end
end
