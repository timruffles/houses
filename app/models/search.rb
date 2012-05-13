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
    classified = classified_tweets.not_boring
    CSV.generate do |csv|
      csv << classified_tweets.first.to_array_titles
      classified_tweets.each do |ct|
        csv << ct.to_array
      end
    end
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
    tweet_ids = classified_tweets.select("distinct(tweet_id)").map(&:tweet_id)
    shared = ClassifiedTweet.group(:tweet_id).where(:tweet_id => tweet_ids).having("count(classified_tweets.id) > 1").map(&:tweet_id)
    ClassifiedTweet.where(:id => classified_tweets.map(&:id)).delete_all
    Tweet.where(:id => (tweet_ids - shared)).delete_all
  end

end
