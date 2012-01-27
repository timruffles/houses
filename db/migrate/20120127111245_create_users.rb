class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :id
      t.integer :twitter_id
      t.string :auth_token
      t.string :twitter_name

      t.timestamps
    end
  end
end
