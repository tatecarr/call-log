class Staff < ActiveRecord::Base
  has_one :staff_info
  has_many :courses
  
  validates_presence_of :first_name, :last_name
end
