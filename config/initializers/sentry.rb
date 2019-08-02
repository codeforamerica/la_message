if defined? Raven
  Raven.configure do |config|
    config.environments = %w(production)
    config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  end
end
