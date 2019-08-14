class RenewalNoticeMessage < CampaignMessage
  def self.recipients
    Contact.opted_in.not_received_message(self)
  end

  def send_message
    body = "It's time to renew your household's Medicaid coverage. "\
           "To keep getting Medicaid, complete your renewal by #{renewal_date}. "\
           "You can now renew online at sspweb.lameds.ldh.la.gov/selfservice "\
           "You can also renew over the phone on week days 8am-5pm at 1-888-342-6207."

    message = contact.messages.create!(
      message_type: self.class.name,
      to_phone_number: contact.phone_number,
      body: body,
      outbound: true
    )

    SmsService.send_message(message)
  end

  private

  def renewal_date
    contact.renewal_date.strftime("%B %-d")
  end
end
