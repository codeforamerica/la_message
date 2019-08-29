require File.expand_path('../config/environment', File.dirname(__FILE__))
require 'csv'

# Need to set Twilio ENV vars before running script:
#
# $ export TWILIO_ACCOUNT_SID=...
# $ export TWILIO_AUTH_TOKEN=...
# # export TWILIO_MESSAGE_SERVICE=...
TWILIO_CLIENT = Twilio::REST::Client.new

def save_contact(phone_number, row)
  contact = Contact.find_or_initialize_by(phone_number: PhoneNumber.format(phone_number))

  unless contact.carrier_type == "mobile"
    contact.list = "wagecheck"
    contact.first_name = row["FIRST_NAME"]
    contact.last_name = row["LAST_NAME"]
    contact.opted_in = true if row["NOTIFICATION_TYPE"] == "TEXT"
    contact.carrier_type = lookup(contact.phone_number)
    puts "saving #{contact.last_name} #{contact.carrier_type}..."
    contact.save
  end
end

def lookup(phone_number)
  response = TWILIO_CLIENT.lookups.phone_numbers(phone_number).fetch(type: ['carrier']).carrier
  if response['type'].present?
    response['type']
  elsif response['error_code'].present?
    "error"
  end
end

csv = CSV.open(ENV['CSV_PATH'], headers: true)
csv.each do |row|
  if row['PH_NUM_CASE'] == "NULL"
    save_contact(row['PH_NUM_APP'], row)
  else
    save_contact(row['PH_NUM_CASE'], row)
  end
end

puts Contact.group(:carrier_type).count
