Hatchboy::Application.routes.draw do
  root :to => "pages#home"
  devise_for :users, :controllers => {:registrations => "registrations"}
  resources :users
end