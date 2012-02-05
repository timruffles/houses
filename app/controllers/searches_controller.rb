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
    @search = Search.find(params[:id])
    @search.update_attributes(params[:search])
    respond_with @search
  end
  def destroy
    @search = Search.find(params[:id])
    @search.destroy
    respond_with @search
  end
end

