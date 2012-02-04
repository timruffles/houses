class SearchesController < ApplicationController
  load_resource
  authorize_resource
  def mine
    @searches = Search.where(:user_id => current_user.id).includes(:classified_tweets)
  end
  def create
  end
  def update
  end
  def destroy
  end
end

