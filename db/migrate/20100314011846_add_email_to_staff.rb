class AddEmailToStaff < ActiveRecord::Migration
  def self.up
    add_column :staffs, :email, :string
  end

  def self.down
    remove_column :staffs, :email
  end
end
