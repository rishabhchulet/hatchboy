Hatchboy::Application.routes.draw do
  root :to => "pages#home"
  devise_for :accounts, :controllers => {:registrations => "registrations"}
  
  get "profile",   :to => "profiles#show", :as => :profile
  get "profile/edit", :to => "profiles#edit", :as => :edit_profile
  put "profile",   :to => "profiles#update"
  patch "profile", :to => "profiles#update"
  
  get "dashboard", :to => "pages#dashboard", :as => :account_dashboard
  
  get "company",   :to => "companies#show"
  get "company/edit", :to => "companies#edit", :as => :edit_company
  put "company",   :to => "companies#update"
  patch "company", :to => "companies#update"
  
end
