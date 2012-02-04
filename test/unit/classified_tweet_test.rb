require 'test_helper'

class ClassifiedTweetTest < ActiveSupport::TestCase
  test "json representation is an augmented tweet" do
    classified = Factory.build(:classified_tweet,:category => "great")
    as_json = classified.as_json
    assert_equal JSON.load(classified.tweet.tweet)['text'], as_json['text']
    assert_equal "great", as_json['category']
  end
end
