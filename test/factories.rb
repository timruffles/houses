FactoryGirl.define do
  factory :user do
    searches
  end
  factory :search do
  end
  factory :tweet do
    tweet File.open("test/fixtures/tweet.json").read
  end
  factory :classified_tweet do
    tweet
  end
end
