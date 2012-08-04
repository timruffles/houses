desc "cleans >1 day old tweets from db"
task :clean_old_tweets => :environment do
	old = ClassifiedTweet.where(["created_at > ?",1.days.ago])
	tweet_ids = old.select("distinct(tweet_id)").map(&:tweet_id)
	old.find_in_batches do |cts|
		cts.each(&:destroy)
	end
	shared = ClassifiedTweet.select("tweet_id, count(id)").group(:tweet_id)\
      .where(:tweet_id => tweet_ids).having("count(id) > 1").map(&:tweet_id)
	Tweet.where(:id => (tweet_ids - shared)).delete_all
end
