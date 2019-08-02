class SmsService
  IGNORABLE_ERROR_MESSAGES = [
    "violates a blacklist rule",
    "is not a valid phone number",
    "is not a mobile number"
  ].freeze

  def self.send_sms(to:, body:)
    twilio_client = Twilio::REST::Client.new
    twilio_client.messages.create(
      messaging_service_sid: Rails.application.secrets.twilio_message_service,
      status_callback: nil,
      to: to,
      body: body
    )
  end

  def self.send_message(message)
    response = send_sms(
      to: format_phone_number(message.to_phone_number),
      body: message.body
    )

    message.update(twilio_id: response.sid)
    message
  rescue Twilio::REST::RestError => e
    if IGNORABLE_ERROR_MESSAGES.any? { |error_message| e.message.include? error_message }
      # TODO: store this in the database somewhere
      Rails.logger.info e.message
    else
      raise
    end
  end

  def self.format_phone_number(phone_number_string)
    return unless phone_number_string && phone_number_string.present?

    cleaned_string = phone_number_string.gsub(/\D+/, "")
    if (cleaned_string.length == 11) && (cleaned_string[0] == '1')
      "+" + cleaned_string
    elsif cleaned_string.length == 10
      "+1" + cleaned_string
    end
  end
end
