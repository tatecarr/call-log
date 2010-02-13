class AddFullInfoToHouse < ActiveRecord::Migration
  def self.up
    add_column :houses, :full_info, :string
  end

  def self.down
    remove_column :houses, :full_info
  end
end
