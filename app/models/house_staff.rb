class HouseStaff < ActiveRecord::Base
  belongs_to :house
  belongs_to :staff
  validates_presence_of :staff_id, :position_name
end
