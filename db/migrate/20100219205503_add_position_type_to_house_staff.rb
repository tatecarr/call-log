class AddPositionTypeToHouseStaff < ActiveRecord::Migration
  def self.up
    add_column :house_staffs, :position_type, :string
  end

  def self.down
    remove_column :house_staffs, :position_type
  end
end
