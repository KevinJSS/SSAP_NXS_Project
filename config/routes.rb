Rails.application.routes.draw do
  resources :projects
  devise_for :users
  root 'main#home'
end
