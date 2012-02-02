class CreateClassifiedTweets < ActiveRecord::Migration
  def change
    create_table :classified_tweets do |t|
      t.integer :search_id
      t.integer :tweet_id
      t.string :category
    end
  end
end
