Hatchboy::Application.routes.draw do
  root :to => "pages#home"
  devise_for :account, :controllers => {:registrations => "registrations"}
  devise_scope :account do
    put "/account/edit", :to => "registrations#update", :as => :update_account_registration
  end
  
  get "account",   :to => "accounts#show", :as => :account
  get "dashboard", :to => "pages#dashboard", :as => :account_dashboard
  
  get "company",   :to => "companies#show"
  get "company/edit", :to => "companies#edit", :as => :edit_company
  put "company",   :to => "companies#update"
  patch "company", :to => "companies#update"
  
end
