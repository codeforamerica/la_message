module Twilio
  class StatusesController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
      message = Message.find_by twilio_id: params[:MessageSid]
      message&.update(
        error_code: params['ErrorCode'],
        error_message: params['ErrorMessage'],
        from_phone_number: params['From'],
        to_phone_number: params['To'],
        status: params['MessageStatus']
      )

      render json: { ok: true }
    end
  end
end
