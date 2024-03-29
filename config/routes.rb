Rails.application.routes.draw do
  resources :minutes
  resources :phases
  resources :activities
  resources :projects do
    collection do
      delete :clear_filters
    end
  end

  devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations', passwords: 'users/passwords' }
  resources :users, only: [:index, :show, :edit, :update]

  # Route for listing collaborator users
  get 'collaborator_users', to: 'users#collaborator_index', as: 'collaborator_users'

  root 'main#home'

  get 'minutes/pdf/:id' => 'minutes#pdf', as: 'minutes_pdf'

  get 'minutes/send_email/:id' => 'minutes#send_email', as: 'minutes_send_email'

  post 'activities_report' => 'activities#activities_report', as: 'activities_report'

  # Ruta para capturar rutas no definidas y redirigir a la acción not_found
  get '*unmatched_route', to: 'application#not_found' 
end
