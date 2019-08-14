class NoReplyMessage < CampaignMessage
  PREVENT_RESEND_DAYS = 1.day

  def on_reply(_reply_message)
    has_recent_message = contact.messages.with_type(self.class).where('created_at > ?', PREVENT_RESEND_DAYS.ago).any?
    return if has_recent_message

    body = "We're unable to confirm any details about your case over text message. "\
           "Please call 1-888-342-6207 for questions about your case."

    message = contact.messages.create!(
      message_type: self.class.name,
      to_phone_number: contact.phone_number,
      body: body,
      outbound: true
    )

    SmsService.send_message(message)
  end
end
