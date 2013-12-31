class CreateWeixinMessages < ActiveRecord::Migration
  def self.up
    create_table :weixin_messages do |t|
      t.string :message_id      
      t.timestamps
    end
  end

  def self.down
    drop_table :weixin_messages
  end
end
