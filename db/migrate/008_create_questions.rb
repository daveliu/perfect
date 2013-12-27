class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      t.string   "image"
      t.string   "music"
      t.string   "options"
      t.string   "answer"
      t.string   "media_id"
      t.timestamps
    end
  end

  def self.down
    drop_table :questions
  end
end
