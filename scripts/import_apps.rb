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
    contact.list = "oct-apps"
    contact.segment = rand(1..12)
    contact.individual_id = row["INDV_ID"]
    contact.first_name = row["FIRST_NAME"]
    contact.last_name = row["LAST_NAME"]
    contact.lameds_opt_in = true if row["NOTIFICATION_TYPE"] == "TEXT"
    contact.opted_in = true if row["NOTIFICATION_TYPE"] == "TEXT"
    contact.carrier_type = lookup(contact.phone_number)

    description = case row['DESCRIPTION']
                  when "SSICompApp" then "Proof of SSI"
                  when "FITAPCompApp" then "Proof of FITAP"
                  when "Earned Income-Interface" then "Earned Income"
                  when "Unsigned LAP Questionnaire" then "Signed LaCHIP Affordable Plan Questionnaire"
                  when "Social Security Number Unverified" then "Proof of Social Security Number"
                  when "CitizenshipInfo" then "Proof of Citizenship"
                  when "Unearned Income-Interface" then "Unearned Income"
                  when "US Citizenship" then "Proof of Citizenship"
                  when "Social Security Number missing" then "Proof of Social Security Number"
                  when "Bank Account" then "Bank Statements"
                  when "ResourceInfo" then "Bank Statements"
                  when "Life Insurance" then "Proof of Life Insurance Policy"
                  when "Burial Plot" then "Burial Contract"
                  when "Access to State Health Coverage" then "Copies of Medical Insurance Cards"
                  when "Incarceration Source" then "Incarceration Details"
                  when "Pregnancy" then "Proof of Pregnancy"
                  when "Verification of resource(s) from Asset Verification System" then nil
                  when "Authorization of Verification of Resources" then nil
                  else
                    row['DESCRIPTION']
                  end

    contact.enrollment_documents << description unless description.blank? || contact.enrollment_documents.include?(description)

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

puts Contact.where(list: "oct-apps").group(:carrier_type).count
