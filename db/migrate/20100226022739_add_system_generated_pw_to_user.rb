class AddSystemGeneratedPwToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :system_generated_pw, :boolean
  end

  def self.down
    remove_column :users, :system_generated_pw
  end
end
