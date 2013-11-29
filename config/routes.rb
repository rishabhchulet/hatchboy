Hatchboy::Application.routes.draw do
  root :to => "pages#home"
  devise_for :accounts, :controllers => {:registrations => "registrations"}
  resources :accounts
end
