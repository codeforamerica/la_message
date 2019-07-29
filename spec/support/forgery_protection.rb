RSpec.configure do |config|
  [:feature, :request].each do |type|
    config.around(type: type) do |example|
      original_value = ActionController::Base.allow_forgery_protection
      ActionController::Base.allow_forgery_protection = true
      example.run
      ActionController::Base.allow_forgery_protection = original_value
    end
  end
end
