class StaffInfo < ActiveRecord::Base
  belongs_to :staff
  acts_as_textiled :experience_prefs, :skills_limits, :schedule_availability, :contact_notes
end
