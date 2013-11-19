class CreateCheers < ActiveRecord::Migration
  def self.up
    create_table :cheers do |t|
      t.string :weixin_token
      t.string :weibo_token
      t.string :weixin_uid
      t.string :weibo_uid
      t.timestamps
    end
  end

  def self.down
    drop_table :cheers
  end
end
