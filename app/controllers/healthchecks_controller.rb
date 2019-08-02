class HealthchecksController < ApplicationController
  def show
    render json: { ok: true }
  end
end
