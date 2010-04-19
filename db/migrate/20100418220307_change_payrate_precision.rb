class ChangePayratePrecision < ActiveRecord::Migration
  def self.up
    change_column :staffs, :payrate, :decimal, :precision => 8, :scale => 2
  end

  def self.down
    change_column :staffs, :payrate, :decimal
  end
end
