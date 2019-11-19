class SurveyMessage < CampaignMessage
  def self.recipients
    Contact.opted_in.mobile.where(list: "nov-renewals", segment: [4, 5, 6])
  end

  def send_message
    body = "Hi, Louisiana Medicaid here. Help us improve by answering a survey about the text messages you received: https://forms.gle/ggG6Qfipz7TjnhM78"
    message = contact.messages.create!(
      message_type: self.class.name,
      to_phone_number: contact.phone_number,
      body: body,
      outbound: true
    )

    SmsService.send_message(message)
  end
end
