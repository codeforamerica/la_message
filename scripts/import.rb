require File.expand_path('../config/environment', File.dirname(__FILE__))
require 'csv'

csv = CSV.open(ENV['CSV_PATH'], headers: true)
csv.each.with_index do |row, index|
  next if row['CELLPH_NUM'] == 'NULL'

  contact = Contact.find_or_initialize_by(phone_number: PhoneNumber.format(row['CELLPH_NUM'])) do |c|
    c.first_name = row['FIRST_NAME']
    c.last_name = row['LAST_NAME']
  end

  # Filter out anyone whose name doesn't match an existing record
  next if contact.first_name != row['FIRST_NAME'] || contact.last_name != row['LAST_NAME']

  description = case row['DESCRIPTION']
                when "SSICompApp" then "Proof of SSI"
                when "Earned Income-Interface" then "Earned Income"
                when "Unsigned LAP Questionnaire" then "Signed LaCHIP Affordable Plan Questionnaire"
                when "Social Security Number Unverified" then "Proof of Social Security Number"
                when "CitizenshipInfo" then "Proof of Citizenship"
                when "Unearned Income-Interface" then "Unearned Income"
                when "US Citizenship" then "Proof of Citizenship"
                when "Social Security Number missing" then "Proof of Social Security Number"
                when "Bank Account" then "Bank Statements"
                when "Life Insurance" then "Proof of Life Insurance Policy"
                when "Burial Plot" then "Burial Contract"
                when "Access to State Health Coverage" then "Copies of Medical Insurance Cards"
                when "Incarceration Source" then "Incarceration Details"
                when "Pregnancy" then "Proof of Pregnancy"
                else
                  row['DESCRIPTION']
                end

  contact.documents << description unless contact.documents.include? description
  contact.opted_in = true if row['NOTIFICATION_TYPE'] == 'TEXT'
  contact.save!

  puts "\n\n==== ROW #{index} ====\n\n" if index.multiple_of?(100)
end
