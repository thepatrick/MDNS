class CreateDomainServerConnections < ActiveRecord::Migration
  def self.up
    create_table :domain_server_connections do |t|
      t.integer :domain_id
      t.integer :server_id
      t.boolean :active

      t.timestamps
    end
  end

  def self.down
    drop_table :domain_server_connections
  end
end
