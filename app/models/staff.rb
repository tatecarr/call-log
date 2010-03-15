class Staff < ActiveRecord::Base
  has_one :staff_info
  has_many :courses
  
  set_primary_key :staff_id
  validates_presence_of :first_name, :last_name
end
