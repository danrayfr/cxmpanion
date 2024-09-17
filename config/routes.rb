Rails.application.routes.draw do
  root "companions#index"

  # post "groq_request", to: "pages#groq_request"
  # post "import", to: "pages#import"

  resources :records, only: %i[ create ]

  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
