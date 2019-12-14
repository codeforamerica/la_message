require File.expand_path('../config/environment', File.dirname(__FILE__))
require 'csv'

csv = CSV.open(ENV['CSV_PATH'], headers: true)
csv.each.with_index do |row, index|
  next if row['CELLPH_NUM'] == 'NULL'

  if (contact = Contact.find_by(phone_number: PhoneNumberFormatter.format(row['CELLPH_NUM'])))
    contact.response = row["RESPONSE"]
    contact.save!
  end

  puts "\n\n==== ROW #{index} ====\n\n" if index.multiple_of?(1000)
end

puts Contact.where(list: "dec-renewals").group(:response).count
