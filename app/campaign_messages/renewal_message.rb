class RenewalMessage < CampaignMessage
  def self.recipients
    Contact.opted_in.mobile.where(list: "nov-renewals", response: "No Packet Returned")
  end

  def send_message
    return if contact.segment.nil?

    body = if (1..6).include?(contact.segment) # Friendly Tone
             "Hi, friendly reminder from Medicaid. "\
             "To keep getting Medicaid, you'll need to complete your renewal by #{renewal_date}. "\
             "You can renew online at sspweb.lameds.ldh.la.gov/selfservice/ "\
             "You can also renew over the phone on week days 8am-5pm at 1-888-342-6207."
           else # Urgent Tone
             "You need to complete your Medicaid renewal by #{renewal_date}. "\
             "You can renew online at sspweb.lameds.ldh.la.gov/selfservice/ "\
             "You can also renew over the phone on week days 8am-5pm at 1-888-342-6207."
           end

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
