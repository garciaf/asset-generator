Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  mount MissionControl::Jobs::Engine, at: "/jobs"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Dashboard
  root "dashboard#index"
  get "dashboard", to: "dashboard#index"

  # Resources for AI asset generation
  resources :styles
  resources :image_requests, only: [ :index, :show, :new, :create ] do
    member do
      post :generate
    end
  end
  resources :images, only: [ :index, :show, :new, :create, :edit, :update, :destroy ]
  resources :variations, only: [ :index, :show, :destroy ]
  resources :variation_requests, only: [ :index, :show, :new, :create ] do
    member do
      post :generate
    end
  end
end
