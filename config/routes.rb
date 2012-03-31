TwitterMlServer::Application.routes.draw do
  match "/" => "main#research", :constraint => { :domain => /^twitter-research/ }
  match "/" => "main#index"

  match "/auth/:provider/callback" => "sessions#create"
  match "/logout" => "sessions#destroy"
  resources :users, :only => [] do
    collection do
      get "me"
    end
  end
  resources :streams, :controller => :searches, :as => :searches, :only => [:create,:update,:destroy] do
    collection do
      get "mine"
    end
    member do
      get "export"
    end
  end
  resources :tweets, :controller => :classified_tweets, :as => :classified_tweets, :only => [:update]
end
