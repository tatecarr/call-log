class Course < ActiveRecord::Base
  validates_uniqueness_of :name, :scope => :staff_id
  belongs_to :staff
end
