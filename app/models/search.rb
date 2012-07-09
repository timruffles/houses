require "csv"
class Search < ActiveRecord::Base
  include PublishesCallbacks
  has_many :classified_tweets
  has_many :tweets, :through => :classified_tweets
  belongs_to :user

  def recently_classified
    classified_tweets.limit(20).order("created_at DESC")
  end

  def to_csv
    classified = classified_tweets.not_boring.includes(:tweet).limit(1000)
    CSV.generate do |csv|
      csv << classified_tweets.first.to_array_titles
      classified_tweets.each do |ct|
        csv << ct.to_array
      end
    end
  end

  def self.clean_up id
    tweet_ids = ClassifiedTweet.where(:search_id => id).select("distinct(tweet_id)").map(&:tweet_id)
    shared = ClassifiedTweet.select("tweet_id, count(id)").group(:tweet_id)\
      .where(:tweet_id => tweet_ids).having("count(id) > 1").map(&:tweet_id)
    ClassifiedTweet.where(:search_id => id).delete_all
    Tweet.where(:id => (tweet_ids - shared)).delete_all
  end

  protected

  after_create do
    publish_callback :after_create, {:keywords => keywords}
  end
  after_update do
    publish_callback :after_update, {:keywords => keywords} if keywords_changed?
  end
  after_destroy do
    publish_callback :after_destroy, {:keywords => keywords}
    Resque.enqueue DelayedCall, Search.class.to_s, :clean_up, id.to_s
  end

end
