class AddWorkPhoneAndStatusToStaff < ActiveRecord::Migration
  def self.up
    add_column :staffs, :work_number, :string
    add_column :staffs, :status, :string
  end

  def self.down
    remove_column :staffs, :status
    remove_column :staffs, :work_number
  end
end
