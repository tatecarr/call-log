class StaffInfo < ActiveRecord::Base
  belongs_to :staff
  # for acts as textiled
  acts_as_textiled :experience_prefs, :skills_limits, :schedule_availability, :contact_notes
end
