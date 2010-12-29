class CreateRecords < ActiveRecord::Migration
  def self.up
    create_table :records do |t|
      t.integer :domain_id, :null => false
      t.string :name, :null => false
      t.string :resource_type
      t.integer :priority
      t.integer :weight
      t.integer :port
      t.string :target

      t.timestamps
    end
  end

  def self.down
    drop_table :records
  end
end
