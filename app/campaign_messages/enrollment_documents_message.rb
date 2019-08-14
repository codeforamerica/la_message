class EnrollmentDocumentsMessage < CampaignMessage
  def self.recipients
    Contact.opted_in.with_documents_due.not_received_message(self)
  end

  def send_message
    body = "To complete your Medicaid application, please submit the following documents soon if you haven't yet:\n\n"

    contact.documents.each do |document|
      body += "* #{document}\n"
    end

    body += "You can drop them off at a Medicaid office, or submit them online at https://sspweb.lameds.ldh.la.gov/selfservice/ "\
            "You can also email them (along with your case number) to mymedicaid@la.gov."

    message = contact.messages.create!(
      message_type: self.class.name,
      to_phone_number: contact.phone_number,
      body: body,
      outbound: true
    )

    SmsService.send_message(message)
  end
end
