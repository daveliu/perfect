class CreateCdks < ActiveRecord::Migration
  def self.up
    create_table :cdks do |t|
      t.string :uid      
      t.string :content
      t.datetime :send_at      
      t.timestamps
    end
  end

  def self.down
    drop_table :cdks
  end
end
