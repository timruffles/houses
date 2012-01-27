class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :id
      t.integer :uid
      t.string :provider
      t.string :name
      t.string :email

      t.timestamps
    end
  end
end
