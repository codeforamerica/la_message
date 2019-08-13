module ClimateControlSupport
  def with_modified_env(options, &block)
    ClimateControl.modify(options) do
      Rails.application.remove_instance_variable(:@secrets) if Rails.application.instance_variable_defined?(:@secrets)
      block.call
    end

    Rails.application.remove_instance_variable(:@secrets) if Rails.application.instance_variable_defined?(:@secrets)
  end
end

RSpec.configure do |config|
  config.include ClimateControlSupport
end
