class AddIndex < ActiveRecord::Migration
  def self.up
    add_index :messages, :token
  end

  def self.down
    remove_index :messages, :token    
  end
end
