TwitterMlServer::Application.routes.draw do
  root :to => "main#index"

  match "/auth/:provider/callback" => "sessions#create"

  resources :searches, :except => [:index] do
    resources :tweets, :only => [:index, :update]
  end
end
