class ClassifiedTweetsController < ApplicationController
  authorize_resource
  respond_to :json
  def update
    @classified_tweet = ClassifiedTweet.find_by_tweet_id!(params[:id])
    @classified_tweet.category = params[:category]
    @classified_tweet.save!
    respond_with @classified_tweet
  end
end
