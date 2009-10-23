class LongerErrorLocations < ActiveRecord::Migration
  def self.up
    change_column :content_errors, :location, :string, :limit => 2000
  end

  def self.down
    change_column :content_errors, :location, :string, :limit => 255
  end
end
