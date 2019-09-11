require File.expand_path('../config/environment', File.dirname(__FILE__))
require 'csv'

# Need to set Twilio ENV vars before running script:
#
# $ export TWILIO_ACCOUNT_SID=...
# $ export TWILIO_AUTH_TOKEN=...
# # export TWILIO_MESSAGE_SERVICE=...
TWILIO_CLIENT = Twilio::REST::Client.new

def save_contact(phone_number, row)
  return if PhoneNumber.format(phone_number).nil?
  contact = Contact.find_or_initialize_by(phone_number: PhoneNumber.format(phone_number))

  unless ["mobile", "landline", "voip"].include?(contact.carrier_type)
    contact.list = "sept-apps"
    contact.individual_id = row["INDV_ID"]
    contact.first_name = row["FIRST_NAME"]
    contact.last_name = row["LAST_NAME"]
    contact.lameds_opt_in = true if row["NOTIFICATION_TYPE"] == "TEXT"
    contact.opted_in = true if row["NOTIFICATION_TYPE"] == "TEXT"
    contact.carrier_type = lookup(contact.phone_number)
    puts "saving #{contact.last_name} #{contact.carrier_type}..."
    contact.save
  end
end

def lookup(phone_number)
  begin
    response = TWILIO_CLIENT.lookups.phone_numbers(phone_number).fetch(type: ['carrier']).carrier
    if response['type'].present?
      response['type']
    elsif response['error_code'].present?
      "error"
    end
  rescue Twilio::REST::RestError
    "error"
  end
end

csv = CSV.open(ENV['CSV_PATH'], headers: true)
csv.each do |row|
  save_contact(row['CELLPH_NUM'], row)
end

puts Contact.where(list: "sept-apps").group(:carrier_type).count
