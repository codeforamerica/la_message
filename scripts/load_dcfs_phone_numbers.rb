require File.expand_path('../config/environment', File.dirname(__FILE__))
require 'csv'
require 'digest'

csv = CSV.open("data/dcfs-all.csv", headers: true)
csv.each do |row|
  full_name = row["name"].strip.titlecase
  first_name = full_name.split(" ")[0].titlecase
  last_name = full_name.split(" ")[-1].titlecase

  tanf_id = row["type"] == "tanf" ? Digest::MD5.hexdigest(full_name) : nil
  snap_id = row["type"] == "snap" ? Digest::MD5.hexdigest(full_name) : nil

  phone_1 = PhoneNumber.find_or_initialize_by(
    phone_number: PhoneNumberFormatter.format(row["phone_1"])
  )
  phone_1.update_attributes(
    tanf_id: tanf_id,
    snap_id: snap_id,
    first_name: first_name,
    last_name: last_name,
    tanf_opt_in: tanf_id.present? && row["opt_in"] == "Y",
    snap_opt_in: snap_id.present? && row["opt_in"] == "Y"
  )

  phone_2 = PhoneNumber.find_or_initialize_by(
    phone_number: PhoneNumberFormatter.format(row["phone_2"])
  )
  phone_2.update_attributes(
    tanf_id: tanf_id,
    snap_id: snap_id,
    first_name: first_name,
    last_name: last_name,
    tanf_opt_in: tanf_id.present? && row["opt_in"] == "Y",
    snap_opt_in: snap_id.present? && row["opt_in"] == "Y"
  )
end
