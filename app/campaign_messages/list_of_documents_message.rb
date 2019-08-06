class ListOfDocumentsMessage < CampaignMessage
  attr_reader :contact

  def self.recipients
    Contact.opted_in.not_received_message(self)
  end

  def initialize(contact)
    @contact = contact
  end

  def send_message
    body = "To complete your Medicaid renewal, please submit the following documents by DATE:\n\n"\
           "You can drop them off at a Medicaid office, or submit them online at sspweb.lameds.ldh.la.gov/selfservice/ "\
           "You can also email them (along with your case number) to mymedicaid@la.gov"

    message = contact.messages.create!(
      message_type: self.class.name,
      to_phone_number: contact.phone_number,
      body: body,
      outbound: true
    )

    SmsService.send_message(message)
  end
end
