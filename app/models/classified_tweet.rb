class ClassifiedTweet < ActiveRecord::Base
  belongs_to :tweet
  belongs_to :search
  def as_json options = {}
    if options[:for_node]
      (super).merge 'tweet' => JSON.load(tweet.tweet)
    else
      json = (super).merge JSON.load(tweet.tweet) # we want tweet id
      json['id'] = json['id'].to_s
      json
    end
  end
  include PublishesCallbacks
  after_create do
    publish_callback :after_update, as_json(:for_node => true)
  end
  after_update do
    return unless category_changed?
    publish_callback :after_update, as_json(:for_node => true)
  end
end
