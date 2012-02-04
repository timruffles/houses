FactoryGirl.define do
  factory :user do
    uid 123
    provider "twitter"
  end
  factory :search do
    user
    keywords "foo, bar"
  end
  factory :tweet do
    tweet File.open("test/fixtures/tweet.json").read
  end
  factory :classified_tweet do
    tweet
    search
    category "great"
  end
end
