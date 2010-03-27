class AddIncludeInReportsToStaffInfo < ActiveRecord::Migration
  def self.up
    add_column :staff_infos, :include_in_reports, :boolean
  end

  def self.down
    remove_column :staff_infos, :include_in_reports
  end
end
