class CreateServerMessages < ActiveRecord::Migration
  def self.up
    create_table :server_messages do |t|
      t.integer :server_id
      t.string :message

      t.timestamps
    end
  end

  def self.down
    drop_table :server_messages
  end
end
