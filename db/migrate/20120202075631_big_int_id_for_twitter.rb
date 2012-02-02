class BigIntIdForTwitter < ActiveRecord::Migration
  def up
    change_column :tweets, :id, :bigint
  end

end
