Hatchboy::Application.routes.draw do
  #resources :docu_signs
  resources :docu_signs do
    member do
      get 'server_response'
    end
  end

  resources :docu_templates do
    get :server_response, :on => :collection
    get :autocomplete_user_name, :on => :collection
  end

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
  get "dashboard", :to => "dashboard#index", :as => :dashboard
  get "legal", :to => "pages#dashboard", :as => :legal

  resources :payments
  resources :paypal_configurations, :only => [:new, :create]
  resources :payment_transactions, :only => [:create]
  post "payment_transactions/paypal_notify", :to => "payment_transactions#paypal_notify", :as => :paypal_notify

  scope "/reports" do
    resources :hours, :controller => 'report_hours', only: [:index], as: :report_hours do
      collection do
        get "team/:team_id", to: "report_hours#team", as: :team
        get "user/:user_id", to: "report_hours#user", as: :user
      end
    end
    resources :payments, :controller => 'report_payments', only: [:index], as: :report_payments do
      get "user/:user_id", to: "report_payments#user", as: :user, on: :collection
    end
    resources :ratings, :controller => 'report_ratings', only: [:index], as: :report_ratings do
      get "user/:user_id", to: "report_ratings#user", as: :user, on: :collection
    end
    resources :mvp, :controller => 'report_mvp', only: [:index], as: :report_mvp do
      get "user/:user_id", to: "report_mvp#user", as: :user, on: :collection
    end
  end
  resources :user_multi_ratings, :only => [:create]

  get "reports", :to => "pages#dashboard", :as => :reports
  get "messages", :to => "pages#dashboard", :as => :messages

  get "mail/", :to => "pages#mail", :as => :account_mail
  get "mail/:folder", :to => "pages#mail", :as => :account_mail_folder
  get "compose", :to => "pages#compose", :as => :compose_mail

  get "company",   :to => "companies#show"
  get "company/edit", :to => "companies#edit", :as => :edit_company
  put "company",   :to => "companies#update"
  patch "company", :to => "companies#update"

  resources :users do
    resource :teams, :to => "teams_users", only: [:destroy] do
      get "new", to: "teams_users#new_team", as: "new", on: :collection
      post "create", to: "teams_users#create_team", as: "create", on: :collection
    end
  end

  resources :subscriptions, only: [:edit, :update]
  delete "/unsubscribed_teams/:id", to: "unsubscribed_teams#subscribe", as: :unsubscribed_team
  get "/subscriptions/unsubscribe", to: "subscriptions#unsubscribe"
  get "/team/:team_id/unsubscribe", to: "unsubscribed_teams#unsubscribe", as: :unsubscribed_teams_unsubscribe

  resources :sources, only: [:index, :new]

  get "jira_sources/callback", :to => "jira_sources#callback", :as => :jira_callback

  resources :jira_sources do
    get "generate_public_cert", :to => "jira_sources", on: :collection
    get "confirm", :to => "jira_sources", :as => :confirm
    get "browse", :to => "jira_sources", :as => :browse
    put "sync", :to => "jira_sources", :as => :sync
  end

  get "trello_sources/callback", :to => "trello_sources#callback", :as => :trello_callback

  resources :trello_sources do
    get "confirm", :to => "trello_sources", :as => :confirm
    get "browse", :to => "trello_sources", :as => :browse
    put "sync", :to => "trello_sources", :as => :sync
  end

  resources :posts

  resources :teams do
    resources :work_logs, except: [:view]
    resources :sources, :to => "teams_sources"
    resources :jira_sources, :to => "teams_jira_sources"
    resources :users, :to => "teams_users", only: [:destroy] do
      get "new", :to => "teams_users#new_user", as: "new", on: :collection
      post "create", :to => "teams_users#create_user", as: "create", on: :collection
    end
  end
end

