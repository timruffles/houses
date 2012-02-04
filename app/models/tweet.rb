class Tweet < ActiveRecord::Base
  has_many :classified_tweets
end
