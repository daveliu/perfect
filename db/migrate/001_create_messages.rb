class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.string :image
      t.string :generated_image
      t.string :name
      t.string :content
      t.string :desc
      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
