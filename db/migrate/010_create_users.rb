class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.boolean  "over_today",               :default => false
      t.integer  "right_answers_counter",    :defualt => 0
      t.string   "uid"
      t.string   "right_question_ids", :default => ""
      t.integer  "last_question_id"      
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
