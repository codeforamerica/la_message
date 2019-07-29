Rails.application.config.paths.add 'app/campaign_messagees', eager_load: true
Rails.application.reloader.to_prepare do
  Dir[Rails.root.join("app", "campaign_messages", "**/*.rb")].each { |file| require_dependency(file) }
end
