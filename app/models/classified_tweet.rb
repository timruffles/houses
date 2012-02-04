class ClassifiedTweet < ActiveRecord::Base
  belongs_to :tweet
  belongs_to :search
  def as_json options = nil
    JSON.load(tweet.tweet).merge(super)
  end
end
