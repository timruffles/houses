class Search < ActiveRecord::Base
  has_many :classified_tweets
  has_many :tweets, :through => :classified_tweets
  belongs_to :user
  before_save do
    return unless keywords.changed?
    redis.publish "modelUpdates", {
      :type => "Search",
      :id => self.id,
      :changed => {
        :keywords => self.keywords
      }
    }.to_json
  end
end
