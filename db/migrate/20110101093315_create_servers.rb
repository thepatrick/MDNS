class CreateServers < ActiveRecord::Migration
  def self.up
    create_table :servers do |t|
      t.string :ip
      t.string :identifier
      t.string :key
      t.boolean :active

      t.timestamps
    end
  end

  def self.down
    drop_table :servers
  end
end
