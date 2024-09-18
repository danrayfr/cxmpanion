Rails.application.routes.draw do
  root "companions#index"

  post "groq_request", to: "companions#groq_request"

  resources :records do
    resources :reviews, except: %i[ index show ]
  end

  resources :prompt_templates, except: :show

  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
