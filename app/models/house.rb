class House < ActiveRecord::Base
#  attr_accessible :bu_code, :behavior_plans, :schedule_info, :keys, :ratio, :city, :address,
#      :name, :zip, :medication_times, :overview, :relief_pay, :phone1, :bu_code, :waivers,
#      :house_staffs_attributes, :phone2, :fax, :trainings_needed, :state
      
  set_primary_key :bu_code
  has_many :house_staffs, :foreign_key => 'bu_code', :dependent => :destroy
  has_many :user_houses, :foreign_key => 'bu_code', :dependent => :destroy
  
  validates_presence_of :bu_code, :name
  
  acts_as_textiled :overview, :trainings_needed, :medication_times, :waivers, :schedule_info, :behavior_plans
end
