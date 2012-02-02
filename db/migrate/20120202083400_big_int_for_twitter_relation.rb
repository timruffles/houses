class BigIntForTwitterRelation < ActiveRecord::Migration
  def up
    change_column :classified_tweets, :tweet_id, :bigint
  end

end
