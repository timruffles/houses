class ClassifiedTweetsController < ApplicationController
  authorize_resource
  def update
    respond_with @classified_tweet = ClassifiedTweet.find_by_tweet_id!(params[:id])
  end
end
