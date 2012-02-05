class Search < ActiveRecord::Base
  has_many :classified_tweets
  has_many :tweets, :through => :classified_tweets
  belongs_to :user
  validates :keywords, :length => {:minimum => 2}
  before_save do
    return unless keywords_changed?
    puts "saving to redis"
    return
    redis.publish "modelUpdates", {
      :type => "Search",
      :id => self.id,
      :changed => {
        :keywords => self.keywords
      }
    }.to_json
  end
end
