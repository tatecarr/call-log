class AddIndividualsAndContactNumbersToHouse < ActiveRecord::Migration
  def self.up
    add_column :houses, :individuals, :text
    add_column :houses, :contact_numbers, :text
  end

  def self.down
    remove_column :houses, :contact_numbers
    remove_column :houses, :individuals
  end
end
