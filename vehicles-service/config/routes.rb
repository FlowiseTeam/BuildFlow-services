Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    resources :vehicles, only: [:index, :show, :create, :update, :destroy]
  end
end