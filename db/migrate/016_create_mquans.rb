class CreateMquans < ActiveRecord::Migration
  def self.up
    create_table :mquans do |t|
      t.string :number
      t.string :password
      t.datetime :send_at
      t.string :uid
      t.integer :user_id      
      t.timestamps
    end
  end

  def self.down
    drop_table :mquans
  end
end
