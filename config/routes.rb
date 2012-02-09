TwitterMlServer::Application.routes.draw do
  root :to => "main#index"

  match "/auth/:provider/callback" => "sessions#create"
  match "/logout" => "sessions#destroy"
  resources :users, :only => [] do
    collection do
      get "me"
    end
  end
  resources :streams, :controller => :searches, :only => [:create,:update,:destroy] do
    collection do
      get "mine"
    end
  end
  resources :tweets, :controller => :classified_tweets, :only => [:update]
end
