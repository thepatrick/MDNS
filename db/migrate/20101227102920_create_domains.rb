class CreateDomains < ActiveRecord::Migration
  def self.up
    create_table :domains do |t|
      t.integer :user_id, :null => false
      t.string :fqdn, :null => false
      t.integer :refresh
      t.integer :retry
      t.integer :expire
      t.integer :default_ttl
      t.integer :version, :default => 1
      t.integer :builds_today, :default => 0
      t.boolean :active, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :domains
  end
end
