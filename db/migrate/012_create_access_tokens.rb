class CreateAccessTokens < ActiveRecord::Migration
  def self.up
    create_table :access_tokens do |t|
      t.string :content               
      t.timestamps
    end
  end

  def self.down
    drop_table :access_tokens
  end
end
