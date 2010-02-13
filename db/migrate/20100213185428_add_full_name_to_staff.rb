class AddFullNameToStaff < ActiveRecord::Migration
  def self.up
    add_column :staffs, :full_name, :string
  end

  def self.down
    remove_column :staffs, :full_name
  end
end
