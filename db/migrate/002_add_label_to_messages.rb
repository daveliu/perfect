class AddLabelToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :label, :string
  end

  def self.down
    remove_column :messages, :label
  end
end
