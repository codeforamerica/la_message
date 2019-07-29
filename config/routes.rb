Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :twilio, module: :twilio do
    resource :incoming, only: :create
  end
end
