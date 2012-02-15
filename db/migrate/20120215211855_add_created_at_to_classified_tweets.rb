class AddCreatedAtToClassifiedTweets < ActiveRecord::Migration
  def change
    add_column :classified_tweets, :created_at, :datetime
  end
end
