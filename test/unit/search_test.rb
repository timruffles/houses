require 'test_helper'

class SearchTest < ActiveSupport::TestCase
  def expect_publish
    @search.expects(:publish_callback).once
  end
  test "publishes updates on create" do
    @search = Factory.build :search
    expect_publish
    @search.save
  end
  test "publishes updates on update" do
    @search = Factory :search
    expect_publish
    @search.keywords = "new keywords"
    @search.save
  end
  test "deletes associated classified tweets + tweets that nobody else has classified" do
    @search = Factory :search
    unshared = [
      Factory(:classified_tweet, :search => @search),
      Factory(:classified_tweet, :search => @search)
    ]
    shared = Factory :classified_tweet, :search => @search
    Factory :classified_tweet, :tweet => shared.tweet
    Resque.expects(:enqueue).once
    @search.destroy
    Search.clean_up @search.id
    assert (unshared.all? {|unshared|
      ClassifiedTweet.find_by_id(unshared.id).nil? && Tweet.find_by_id(unshared.tweet.id).nil?
    }), "should have deleted all classified tweets and unshared tweets of search"
    assert ClassifiedTweet.find_by_id(shared.id).nil?, "should delete classified tweet"
    assert Tweet.find_by_id(shared.tweet.id).nil? == false, "should not delete a shared tweet of a search"
  end
end
