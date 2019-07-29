class RenewalNoticeMessage
  attr_reader :contact

  def self.send_to_contacts
    Contact.where("created_at < ?", 10.days.ago).find_each do |contact|
      new(contact).send_message
    end
  end

  def initialize(contact)
    @contact = contact
  end

  def send_message
    body = "It is time to renew your household's Medicaid coverage. "\
            "To keep getting Medicaid, complete your renewal by #{contact.renewal_date}. "\
            "You can now renew online at sspweb.lameds.ldh.la.gov/selfservice "\
            "You can also renew over the phone on week days 8am-5pm at 1-888-342-6207."

    message = contact.messages.create!(
      message_type: self.class.name,
      to_phone_number: contact.phone_number,
      body: body
    )

    SmsService.send_message(message)
  end
end
