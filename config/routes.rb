Rails.application.routes.draw do
  resources :activities
  resources :projects
  devise_for :users, controllers: { sessions: 'users/sessions' }

  root 'main#home'
end
