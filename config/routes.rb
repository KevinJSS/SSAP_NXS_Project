Rails.application.routes.draw do
  resources :minutes
  resources :phases
  resources :activities
  resources :projects

  devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations' }
  resources :users, only: [:index, :show, :edit, :update]

  # Route for listing collaborator users
  get 'collaborator_users', to: 'users#collaborator_index', as: 'collaborator_users'

  root 'main#home'
end
