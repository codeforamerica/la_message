require File.expand_path('../config/environment', File.dirname(__FILE__))
require 'csv'

csv = CSV.open(ENV['CSV_PATH'], headers: true)
no_count = yes_count = 0
csv.each.with_index do |row, index|
  next if row['CELLPH_NUM'] == 'NULL'

  if contact = Contact.find_by(phone_number: PhoneNumber.format(row['CELLPH_NUM']))
    # flip the logic: if there's no verification pending, the client did indeed respond
    if row['VERIFICATION_PENDING'] == "N"
      contact.response = "yes"
      yes_count += 1
    else
      contact.response = "no"
      no_count += 1
    end
    contact.save!
  end

  puts "\n\n==== ROW #{index} ====\n\n" if index.multiple_of?(100)
end

puts "# of 'no': #{no_count}"
puts "# of 'yes': #{yes_count}"
