class ClassifiedTweet < ActiveRecord::Base
  belongs_to :tweet
  belongs_to :search
  scope :not_boring, where("category != 'boring'")
  def as_json options = {}
    if options[:for_node]
      (super).merge :tweet => JSON.load(tweet.tweet)
    else
      json = (super).merge JSON.load(tweet.tweet) # we want tweet id
      json[:id] = json[:id].to_s
      json
    end
  end
  def array_format
    base = ["id_str", "text", {"user" => ["screen_name", "created_at", "url", "name", "id_str"]}]
    as_hash = self.as_json.merge(:tweet => JSON.load(tweet.tweet))
    all = as_hash.keys
    exclude = ["user","entities","category","search_id","tweet_id","updated_at"]
    base + (all - base - exclude)
  end
  def to_array
    ArrayRepresentation.format as_hash, array_format
  end
  def to_array_titles
    ArrayRepresentation.titles array_format
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
