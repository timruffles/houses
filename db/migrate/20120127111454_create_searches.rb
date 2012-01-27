class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.integer :id
      t.integer :user_id
      t.string :keywords

      t.timestamps
    end
  end
end
