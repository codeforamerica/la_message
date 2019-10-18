require File.expand_path('../config/environment', File.dirname(__FILE__))
require 'csv'

def save_contact(phone_number, row)
  return if PhoneNumber.format(phone_number).nil?

  if (contact = Contact.find_by(phone_number: PhoneNumber.format(phone_number)))
    contact.list = "aug-apps"
    contact.response = row['VERIFICATION_PENDING'] == "Y" ? "no" : "yes"
    puts "#{contact.phone_number}: #{contact.response}"
    contact.save
  end
end

csv = CSV.open(ENV['CSV_PATH'], headers: true)
csv.each do |row|
  save_contact(row['CELLPH_NUM'], row)
end

puts Contact.where(list: "aug-apps").group(:response).count
