class AddZoneFileToDomain < ActiveRecord::Migration
  def self.up
    add_column :domains, :zone_file, :text
  end

  def self.down
    remove_column :domains, :zone_file
  end
end
