require File.expand_path('../config/environment', File.dirname(__FILE__))
require 'csv'

csv = CSV.open(ENV['CSV_PATH'], headers: true)
csv.each.with_index do |row, index|
  if (contact = Contact.find_by(phone_number: PhoneNumberFormatter.format(row['PH_NUM_APP'])))
    contact.response = row["VERIFICATION_RETURNED"]
    contact.save!
  end

  if (contact = Contact.find_by(phone_number: PhoneNumberFormatter.format(row['PH_NUM_CASE'])))
    contact.response = row["VERIFICATION_RETURNED"]
    contact.save!
  end

  puts "\n\n==== ROW #{index} ====\n\n" if index.multiple_of?(1000)
end

puts Contact.where(list: "wagecheck").group(:response).count
