class AddOrgLevelToStaff < ActiveRecord::Migration
  def self.up
    add_column :staffs, :org_level, :integer
  end

  def self.down
    remove_column :staffs, :org_level
  end
end
