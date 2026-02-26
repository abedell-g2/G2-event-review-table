Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "entries#index"
  resources :entries, only: [:index, :create, :update, :destroy]
  post "entries/import", to: "imports#create", as: :import_entries
end
