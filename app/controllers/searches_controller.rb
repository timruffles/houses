class SearchesController < ApplicationController
  load_resource
  authorize_resource
  respond_to :json
  def mine
    @searches = Search.where(:user_id => current_user.id).includes(:classified_tweets)
    respond_with @searches
  end
  def create
    respond_with current_user.searches.create params[:search]
  end
  def update
    respond_with Search.find(params[:id]).update_attributes(params[:search])
  end
  def destroy
    respond_with Search.find(params[:id]).destroy
  end
end

