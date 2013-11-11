class AddUidToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :uid, :string
  end

  def self.down
    remove_column :messages, :uid
  end
end
