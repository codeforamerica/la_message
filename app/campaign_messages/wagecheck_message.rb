class WagecheckMessage < CampaignMessage
  def self.recipients
    Contact.where(opted_in: true, list: "wagecheck").not_received_message(self)
  end

  def send_message
    body = "You are at risk of losing your health coverage. "\
           "We have mailed you a letter asking for information we need to determine "\
           "if you’re eligible to keep your coverage. "\
           "You must reply by the deadline on that letter. "\
           "If you did not receive the letter or have questions, "\
           "you can call us at 1-888-342-6207, weekdays 7 a.m. to 6 p.m."

    message = contact.messages.create!(
      message_type: self.class.name,
      to_phone_number: contact.phone_number,
      body: body,
      outbound: true
    )

    SmsService.send_message(message)
  end
end
