class DataQuality < ActiveRecord::Migration
  def up
    change_table "classified_tweets", :force => true do |t|
      t.change "search_id", :integer,  :null => false
      t.change "tweet_id", :integer,   :limit => 8, :null => false
      t.change "category", :string,  :null => false
    end

    change_table "searches", :force => true do |t|
      t.change "user_id", :integer,  :null => false
      t.change "keywords", :string,  :null => false
    end

    change_table "tweets", :force => true do |t|
      t.change "tweet", :text,  :null => false
    end

    change_table "users", :force => true do |t|
      t.change "uid", :integer,  :null => false
      t.change "provider", :string,  :null => false
    end
  end

end
