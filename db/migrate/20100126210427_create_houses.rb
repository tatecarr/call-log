class CreateHouses < ActiveRecord::Migration
  def self.up
    create_table :houses do |t|
      t.integer :bu_code
      t.string :name
      t.string :address
      t.string :city
      t.string :state
      t.string :zip
      t.string :phone1
      t.string :phone2
      t.string :fax
      t.text :overview
      t.string :ratio
      t.text :trainings_needed
      t.text :medication_times
      t.string :relief_pay
      t.text :waivers
      t.string :keys
      t.text :schedule_info
      t.text :behavior_plans

      t.timestamps
    end
  end

  def self.down
    drop_table :houses
  end
end
