Rails.application.routes.draw do
  resources :minutes
  resources :phases
  resources :activities
  resources :projects
  devise_for :users, controllers: { sessions: 'users/sessions' }

  root 'main#home'
end
