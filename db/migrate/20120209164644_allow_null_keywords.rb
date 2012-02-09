class AllowNullKeywords < ActiveRecord::Migration
  def change
    change_column :searches, :keywords, :string, :null => true
  end

end
