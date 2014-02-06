Hatchboy::Application.routes.draw do
  root :to => "pages#home"
  devise_for :account, :controllers => {:registrations => "registrations" }, skip: [:invitations]

  devise_scope :account do
    put   "/account/edit", :to => "registrations#update", :as => :update_account_registration
    get   "/account/invitation/accept", :to =>  "devise/invitations#edit", :as => :accept_account_invitation
    get   "/account/invitation/remove", :to =>  "devise/invitations#destroy", :as => :remove_account_invitation
    patch "/account/invitation", :to =>  "devise/invitations#update"
    put   "/account/invitation", :to =>  "devise/invitations#update", :as => :update_account_invitation
    get   "/account/invitation/new", :to =>  "invitations#new", :as => :new_user_invitation
    post  "/account/invitation/new", :to =>  "invitations#create", :as => :create_user_invitation
  end

  get "account",   :to => "accounts#show", :as => :account
  get "dashboard", :to => "pages#dashboard", :as => :account_dashboard
  get "legal", :to => "pages#dashboard", :as => :legal
  get "payments", :to => "pages#dashboard", :as => :payments
  get "reports", :to => "pages#dashboard", :as => :reports
  get "messages", :to => "pages#dashboard", :as => :messages

  get "mail/", :to => "pages#mail", :as => :account_mail
  get "mail/:folder", :to => "pages#mail", :as => :account_mail_folder
  get "compose", :to => "pages#compose", :as => :compose_mail

  get "company",   :to => "companies#show"
  get "company/edit", :to => "companies#edit", :as => :edit_company
  put "company",   :to => "companies#update"
  patch "company", :to => "companies#update"

  resources :users
  resources :sources, only: [:index, :new]

  get "jira_sources/callback", :to => "jira_sources#callback", :as => :jira_callback

  resources :jira_sources do
    get "confirm", :to => "jira_sources", :as => :confirm
    get "browse", :to => "jira_sources", :as => :browse
    get "sync", :to => "jira_sources", :as => :sync
  end

  resources :teams do
    resources :work_logs, except: [:view]
    resources :sources, :to => "teams_sources"
    resources :jira_sources, :to => "teams_jira_sources"
    resources :users, only: [:new, :create, :destroy], :to => "teams_users"
  end
end

