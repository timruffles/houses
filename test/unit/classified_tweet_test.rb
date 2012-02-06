require 'test_helper'

class ClassifiedTweetTest < ActiveSupport::TestCase
  test "json representation is an augmented tweet" do
    classified = Factory.build(:classified_tweet,:category => "great",:search_id => 10)
    as_json = classified.as_json
    assert_equal JSON.load(classified.tweet.tweet)['text'], as_json['tweet']['text']
    assert_equal "great", as_json['category']
  end
  test "publishes attributes when category changes" do
    tweet = Factory :classified_tweet
    tweet.category = "crap"
    tweet.expects(:publish_callback).with do |callback,attrs|
      "crap" == attrs["category"]
    end
    tweet.save
  end
end
