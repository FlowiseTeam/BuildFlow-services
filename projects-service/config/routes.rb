Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    resources :projects, only: [:index, :show, :create, :update, :destroy] do
      resources :comments, only: [:index, :show, :create, :update, :destroy]
    end
  end
end
