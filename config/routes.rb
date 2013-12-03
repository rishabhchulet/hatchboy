Hatchboy::Application.routes.draw do
  root :to => "pages#home"
  devise_for :accounts, :controllers => {:registrations => "registrations"}
  resources :accounts
  
  get "dashboard", :to => "pages#dashboard", :as => :account_dashboard
  get "company", :to => "companies#show"
  resources :companies, :only => [:edit, :update]
  
end
