Rails.application.routes.draw do
  resources :minutes
  resources :phases
  resources :activities
  resources :projects

  devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations' }
  # Ruta personalizada para users#index
  resources :users, only: [:index, :show]

  root 'main#home'
end
