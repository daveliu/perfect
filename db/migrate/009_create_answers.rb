class CreateAnswers < ActiveRecord::Migration
  def self.up
    create_table :answers do |t|
      t.string   "uid"
      t.string   "content"
      t.integer  "message_id"
      t.integer  "user_id"
      t.boolean  "result",     :default => false      
      t.timestamps
    end
  end

  def self.down
    drop_table :answers
  end
end
