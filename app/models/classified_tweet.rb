class ClassifiedTweet < ActiveRecord::Base
  belongs_to :tweet
  belongs_to :search
  def as_json options = nil
    json = (super).merge JSON.load(tweet.tweet)
    json['id'] = json['id'].to_s
    json
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
