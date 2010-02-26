class CreateStaffInfos < ActiveRecord::Migration
  def self.up
    create_table :staff_infos do |t|
      t.integer :staff_id
      t.text :experience_prefs
      t.text :skills_limits
      t.text :schedule_availability
      t.text :contact_notes

      t.timestamps
    end
  end

  def self.down
    drop_table :staff_infos
  end
end
