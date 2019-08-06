module TwilioSystemSpecHelpers
  def twilio_response
    @number = @number ? @number + 1 : 1
    OpenStruct.new(sid: @number)
  end

  def incoming_sms(phone_number:, body:)
    post twilio_incoming_url, params: {
      "Body": body,
      "To": "+15555555555",
      "From": phone_number,
    }
  end
end

RSpec.configure do |config|
  config.include TwilioSystemSpecHelpers, type: :system
end
