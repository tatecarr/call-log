class HouseStaff < ActiveRecord::Base
  belongs_to :house
  validates_presence_of :staff_id, :position_name
end
