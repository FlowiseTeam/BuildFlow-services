Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  namespace :api, defaults: { format: :json } do
    get 'projects/comments/latest', to: 'comments#latest'

    # Employee_Assignments Routing
    get 'projects/employee_assignments', to: 'employee_assignments#show'
    post 'projects/employee_assignments', to: 'employee_assignments#create'
    delete 'projects/employee_assignments', to: 'employee_assignments#destroy'

    # Vehicle_Assignments Routing
    get 'projects/vehicle_assignments', to: 'vehicle_assignments#show'
    post 'projects/vehicle_assignments', to: 'vehicle_assignments#create'
    delete 'projects/vehicle_assignments', to: 'vehicle_assignments#destroy'

    # Projects Routing
    get 'projects', to: 'projects#index'
    get 'projects/:id', to: 'projects#show'
    post 'projects', to: 'projects#create'
    delete 'projects/:id', to: 'projects#destroy'
    put 'projects/:id', to: 'projects#update'

    resources :projects, only: [] do #, :show:index, :create, :update, :destroy
      resources :comments, only: [:index, :show, :create, :update, :destroy]
    end
  end
end