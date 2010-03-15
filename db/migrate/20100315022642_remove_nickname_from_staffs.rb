class RemoveNicknameFromStaffs < ActiveRecord::Migration
  def self.up
    remove_column :staffs, :nickname
  end

  def self.down
    add_column :staffs, :nickname, :string
  end
end
