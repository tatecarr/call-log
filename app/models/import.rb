class Import < ActiveRecord::Base
  #Paperclip
  has_attached_file :csv
  validates_attachment_presence :csv
end
