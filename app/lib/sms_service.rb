class SmsService
  IGNORABLE_ERROR_MESSAGES = [
    "violates a blacklist rule",
    "is not a valid phone number",
    "is not a mobile number",
  ].freeze

  def self.send_message(message)
    response = send_sms(
      to: message.to_phone_number,
      body: message.body
    )

    message.update(twilio_id: response.sid)
    message
  rescue Twilio::REST::RestError => e
    if IGNORABLE_ERROR_MESSAGES.any? { |error_message| e.message.include? error_message }
      message.update(error_message: e.message)
      message
    else
      raise
    end
  end

  def self.send_sms(to:, body:)
    twilio_client = Twilio::REST::Client.new
    twilio_client.messages.create(
      messaging_service_sid: Rails.application.secrets.twilio_message_service,
      to: PhoneNumber.format(to),
      body: body
      # status_callback: nil
    )
  end
end
