class SystemSetting < ActiveRecord::Base
  validates_numericality_of :session_timeout
end
