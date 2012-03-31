class Search < ActiveRecord::Base
  include PublishesCallbacks
  has_many :classified_tweets
  has_many :tweets, :through => :classified_tweets
  belongs_to :user

  def recently_classified
    classified_tweets.limit(20).order("created_at DESC")
  end

  def to_csv params
    classified = search.classified_tweets.not_boring
    CSV.generate do |csv|
      csv << classified.shift.to_array
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
  end


end
