# == Schema Information
#
# Table name: phone_numbers
#
#  id              :bigint           not null, primary key
#  first_name      :string
#  last_name       :string
#  medicaid_opt_in :integer          default("no_response")
#  opt_in          :boolean          default(FALSE)
#  phone_number    :string
#  sms_deliverable :integer          default("unknown")
#  snap_opt_in     :integer          default("no_response")
#  tanf_opt_in     :integer          default("no_response")
#  wic_opt_in      :integer          default("no_response")
#  medicaid_id     :string
#  snap_id         :string
#  tanf_id         :string
#  wic_id          :string
#

class PhoneNumber < ApplicationRecord
  enum sms_deliverable: [:unknown, :yes, :no]
  enum medicaid_opt_in: [:no_response, :yes, :no], _prefix: :medicaid
  enum wic_opt_in: [:no_response, :yes, :no], _prefix: :wic
  enum snap_opt_in: [:no_response, :yes, :no], _prefix: :snap
  enum tanf_opt_in: [:no_response, :yes, :no], _prefix: :tanf
end
