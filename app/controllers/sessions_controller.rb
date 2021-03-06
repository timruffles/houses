class SessionsController < ApplicationController
  skip_authorization_check
  layout false
  def create
    auth = request.env["omniauth.auth"]
    if user = User.find_by_provider_and_uid(auth["provider"], auth["uid"])
      user.oauth_token = auth["credentials"]["token"]
      user.oauth_secret = auth["credentials"]["secret"]
      user.save
    else
      user = User.create_with_omniauth(auth)
    end
    session[:user_id] = user.id
    redirect_to "/"
  end
  def destroy
    session.delete(:user_id)
    redirect_to "/"
  end
end
