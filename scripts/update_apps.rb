require File.expand_path('../config/environment', File.dirname(__FILE__))
require 'csv'

def save_contact(phone_number, row)
  return if PhoneNumber.format(phone_number).nil?

  if (contact = Contact.find_by(phone_number: PhoneNumber.format(phone_number)))
    # description = case row['DESCRIPTION']
    #               when "SSICompApp" then "Proof of SSI"
    #               when "Earned Income-Interface" then "Earned Income"
    #               when "Unsigned LAP Questionnaire" then "Signed LaCHIP Affordable Plan Questionnaire"
    #               when "Social Security Number Unverified" then "Proof of Social Security Number"
    #               when "CitizenshipInfo" then "Proof of Citizenship"
    #               when "Unearned Income-Interface" then "Unearned Income"
    #               when "US Citizenship" then "Proof of Citizenship"
    #               when "Social Security Number missing" then "Proof of Social Security Number"
    #               when "Bank Account" then "Bank Statements"
    #               when "Life Insurance" then "Proof of Life Insurance Policy"
    #               when "Burial Plot" then "Burial Contract"
    #               when "Access to State Health Coverage" then "Copies of Medical Insurance Cards"
    #               when "Incarceration Source" then "Incarceration Details"
    #               when "Pregnancy" then "Proof of Pregnancy"
    #               else
    #                 row['DESCRIPTION']
    #               end
    #
    # contact.enrollment_documents << description unless contact.enrollment_documents.include? description

    contact.response = row['VERIFICATION_PENDING'] == "Yes" ? "no" : "yes"
    puts "#{contact.phone_number}: #{contact.response}"
    contact.save
  end
end

csv = CSV.open(ENV['CSV_PATH'], headers: true)
csv.each do |row|
  save_contact(row['CELLPH_NUM'], row)
end
