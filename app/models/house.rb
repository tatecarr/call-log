class House < ActiveRecord::Base
      
  set_primary_key :bu_code
  has_many :house_staffs, :foreign_key => 'bu_code', :dependent => :destroy
  has_many :user_houses, :foreign_key => 'bu_code', :dependent => :destroy
  
  validates_presence_of :bu_code, :name
  validates_uniqueness_of :bu_code, :name
  validates_numericality_of :bu_code
end
