TwitterMlServer::Application.routes.draw do
  root :to => "main#index"

  match "/auth/:provider/callback" => "sessions#create"
  resources :users, :only => [] do
    collection do
      get "me"
    end
  end
  resources :searches, :only => [:create,:update,:destroy] do
    collection do
      get "mine"
    end
  end
  resources :classified_tweets, :only => [:update]
end
