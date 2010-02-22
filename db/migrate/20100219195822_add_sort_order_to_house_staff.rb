class AddSortOrderToHouseStaff < ActiveRecord::Migration
  def self.up
    add_column :house_staffs, :sort_order, :string
  end

  def self.down
    remove_column :house_staffs, :sort_order
  end
end
