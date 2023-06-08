Rails.application.routes.draw do
  resources :projects
  devise_for :users, controllers: { sessions: 'users/sessions' }

  root 'main#home'
end
