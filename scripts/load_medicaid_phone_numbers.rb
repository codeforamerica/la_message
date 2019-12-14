require File.expand_path('../config/environment', File.dirname(__FILE__))

Contact.all.each do |contact|
  phone_number = PhoneNumber.find_or_initialize_by(phone_number: contact.phone_number)

  sms_deliverable = if contact.carrier_type == "mobile"
    "yes"
  elsif contact.carrier_type.blank?
    "unknown"
  else
    "no"
  end

  phone_number.update_attributes(
    medicaid_id: contact.individual_id || Digest::MD5.hexdigest(contact.phone_number + contact.last_name),
    first_name: contact.first_name.titlecase,
    last_name: contact.last_name.titlecase,
    medicaid_opt_in: !!contact.opted_in,
    sms_deliverable: sms_deliverable
  )
end
