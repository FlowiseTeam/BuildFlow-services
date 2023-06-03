Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    resources :projects, only: [:index, :show, :create, :update, :destroy] do
      get '/employee_assignments', to: 'employee_assignments#show_by_project'
      get '/employee_assignments/:employee_id', to: 'employee_assignments#show_by_employee', as: 'show_employee_assignments'
      resources :comments, only: [:index, :show, :create, :update, :destroy]
      resources :employee_assignments, only: [ :create, :destroy]
    end
  end
end
