class RemoveStateAndZipFromStaff < ActiveRecord::Migration
  def self.up
    remove_column :staffs, :state
    remove_column :staffs, :zip
  end

  def self.down
    add_column :staffs, :zip, :string
    add_column :staffs, :state, :string
  end
end
