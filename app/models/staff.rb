class Staff < ActiveRecord::Base
  belongs_to :staff_info
  
  validates_presence_of :first_name, :last_name
end
