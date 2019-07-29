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
    body = "To complete your Medicaid renewal, please submit the following documents by DATE:\n\n"\
           "You can drop them off at a Medicaid office, or submit them online at sspweb.lameds.ldh.la.gov/selfservice/. "\
           "You can also email them (along with your case number) to mymedicaid@la.gov."

    message = contact.messages.create!(
      message_type: self.class.name,
      to_phone_number: contact.phone_number,
      body: body
    )

    SmsService.send_message(message)
  end
end
