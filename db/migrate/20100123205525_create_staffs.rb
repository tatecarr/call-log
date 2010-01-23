class CreateStaffs < ActiveRecord::Migration
  def self.up
    create_table :staffs do |t|
      t.integer :staff_id
      t.string :first_name
      t.string :last_name
      t.string :nickname
      t.string :address
      t.string :city
      t.string :state
      t.string :zip
      t.string :gender
      t.date :doh
      t.string :cell_number
      t.string :home_number
      t.boolean :agency_staff

      t.timestamps
    end
  end

  def self.down
    drop_table :staffs
  end
end
