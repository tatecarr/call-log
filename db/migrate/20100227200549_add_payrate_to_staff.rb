class AddPayrateToStaff < ActiveRecord::Migration
  def self.up
    add_column :staffs, :payrate, :decimal
  end

  def self.down
    remove_column :staffs, :payrate
  end
end
