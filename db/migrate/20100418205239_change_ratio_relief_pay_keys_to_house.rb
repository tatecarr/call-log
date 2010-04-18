class ChangeRatioReliefPayKeysToHouse < ActiveRecord::Migration
  def self.up
    change_column :houses, :ratio, :text
    change_column :houses, :relief_pay, :text
    change_column :houses, :keys, :text
  end

  def self.down
    change_column :houses, :ratio, :string
    change_column :houses, :relief_pay, :string
    change_column :houses, :keys, :string
  end
end
