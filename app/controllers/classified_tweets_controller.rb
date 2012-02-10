class ClassifiedTweetsController < ApplicationController
  authorize_resource
  def update
    @classified_tweet = ClassifiedTweet.find_by_tweet_id! params[:id]
  end
end
