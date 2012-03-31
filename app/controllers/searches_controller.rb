class SearchesController < ApplicationController
  load_resource
  authorize_resource
  respond_to :json
  class SearchPresenter
    def initialize search
      @search = search
    end
    def as_json opts = {}, &block
      @search.as_json.merge(
        :tweets => @search.recently_classified.map(&:as_json)
      )
    end
  end
  def mine
    @searches = Search.where(:user_id => current_user.id)
    respond_with @searches.map {|s| SearchPresenter.new s }
  end
  def create
    respond_with current_user.searches.create :keywords => params[:keywords]
  end
  def update
    @search = Search.find(params[:id])
    @search.keywords = params[:keywords]
    @search.save
    respond_with @search
  end
  def destroy
    @search = Search.find(params[:id])
    @search.destroy
    respond_with @search
  end
  def export
    csv = Search.find(params[:id]).to_csv
    render :text => csv, :content_type => Mime::CSV
  end
end

