class AddOvertimeToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :overtime, :datetime
  end

  def self.down
  end
end
