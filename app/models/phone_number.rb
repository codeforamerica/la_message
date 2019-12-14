# == Schema Information
#
# Table name: phone_numbers
#
#  id              :bigint           not null, primary key
#  first_name      :string
#  last_name       :string
#  medicaid_opt_in :boolean          default(FALSE)
#  opt_in          :boolean          default(FALSE)
#  phone_number    :string
#  sms_deliverable :integer          default("unknown")
#  snap_opt_in     :boolean          default(FALSE)
#  tanf_opt_in     :boolean          default(FALSE)
#  wic_opt_in      :boolean          default(FALSE)
#  medicaid_id     :string
#  snap_id         :string
#  tanf_id         :string
#  wic_id          :string
#

class PhoneNumber < ApplicationRecord
  enum sms_deliverable: [:unknown, :yes, :no]
end
