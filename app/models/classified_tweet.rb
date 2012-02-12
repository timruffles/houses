class ClassifiedTweet < ActiveRecord::Base
  belongs_to :tweet
  belongs_to :search
  def as_json options = nil
    (super).merge 'tweet' => JSON.load(tweet.tweet)
  end
  include PublishesCallbacks
  after_create do
    publish_callback :after_update, as_json
  end
  after_update do
    return unless category_changed?
    publish_callback :after_update, as_json
  end
end
