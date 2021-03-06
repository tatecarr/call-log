# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)
unless SystemSetting.first
  SystemSetting.create!(:session_timeout => 60)
end

unless User.find_by_username('admin')
  User.create!(:username => 'admin', 
              :email => 'test@nearc.com', 
              :password => "nearc",
              :role => 'System-Admin',
              :system_generated_pw => false)
end