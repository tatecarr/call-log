class CreateHouseStaffs < ActiveRecord::Migration
  def self.up
    create_table :house_staffs do |t|
      t.integer :bu_code
      t.integer :staff_id
      t.string :position_name

      t.timestamps
    end
  end

  def self.down
    drop_table :house_staffs
  end
end
