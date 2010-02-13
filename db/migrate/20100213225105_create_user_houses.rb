class CreateUserHouses < ActiveRecord::Migration
  def self.up
    create_table :user_houses do |t|
      t.integer :bu_code
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :user_houses
  end
end
