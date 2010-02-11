#-----------------------------------------------------------------------------------
# admin_controller.rb
#
# Handles all actions and logic for the admin section of the call log
#
# Written By: Ben Vogelzang 1/28/10
#
#-----------------------------------------------------------------------------------
class AdminController < ApplicationController


#-------------------------- Actions for displaying pages ---------------------------
 
  def index
    @import = Import.new
    @user = User.new
    @users = User.all
  end

  def show
    @import = Import.find(params[:id])
	end


#---------------------- Actions executed after form submission ----------------------

  # add a user and email their login credentials with a temporary password
	def add_user
	  
	  # create their username from the first part of their email
	  login = params[:user][:email].split("@")[0]
	  params[:user][:username] = login
    
    # generate a random temporary password
    params[:user][:password] = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--")[0,6]
	  params[:user][:password_confirmation] = params[:user][:password]
	  
	  # create the user with the new credentials
	  @user = User.new(params[:user])
	  
	  # try and save the user to the db
	  if @user.save
	    
	    # if we were successful send an email to the user containing their login info
	    UserMailer.deliver_registration_confirmation(@user)
	    flash[:notice] = "User account was successfully created."
    else
      
      # if we get here the only thing that could have gone wrong is that the email wasn't valid
      # since the form only allows one input
      flash[:error] = "The user was not created. Please enter a valid email address."
    end
    
    redirect_to :action => 'index'
  end


  # import a csv file from upload
  def import_csv
    
    # upload and save the file
    @import = Import.new(params[:import])
    @import.save
    
    # read the csv file into a 2-d array
    lines = parse_csv_file(@import.csv.path)
    
    
    # Provides and easy way for us to access the column header position when adding people later.
    #
    # We start with an array of column headers: 
    #
    #     lines[0] = ["person_id", "first_name", "last_name", etc. ]
    #
    # We transform this into Hash containing the column header as the key and column position 
    # as the value. @row_positions will end up looking something like the example below:
    #
    #     @row_positions = {:person_id => 1, :last_name => 3, :first_name => 2, etc. }
    #
    @row_positions = Hash[ *lines[0].map { |v| [ v.to_sym, lines[0].index(v) ] }.flatten ]

    # we don't want to add the column headers as a person so remove them
    lines.shift
    
    # make sure we have people to import
    if lines.size > 0
      
      # delete all the staff that aren't agency staff
      Staff.delete_all(["agency_staff = ?", false])
      
      # step through the file and add a person for each line
      lines.each do |line|
          add_person(line)
      end
      
      # we don't need the file anymore so we can remove it
      @import.destroy
      
      flash[:notice] = "CSV data processing was successful."
      redirect_to staffs_url
    else
      
      flash[:error] = "The file did not contain any people. Please make sure there are people in the file."
      render :action => "show", :id => @import.id
    end
	end
	
	
	
	# provide a backup of the mysql database for download
	def backup
	  require 'erb'
    require 'yaml'

    # make sure that we're set up to connnect to a database
    unless config = YAML::load(ERB.new(IO.read(RAILS_ROOT + "/config/database.yml")).result)[RAILS_ENV]
      abort "No database is configured for the environment '#{RAILS_ENV}'"
    end

    # to make the file name unique, use today's date. There shouldn't be a need any more backups than that
    now = Time.now.strftime("%m_%d_%Y")
    
    # open a shell and perform a mysql dump into a file
    success = system "/usr/local/mysql/bin/mysqldump -u root #{config['database']} > call_log_backup_#{now}.sql"
    
    if success
      # if we were successful backing up the file, move it to a place where it can be downloaded
      system "mv call_log_backup_#{now}.sql public/call_log_backup_#{now}.sql"
    else
      # something went wrong with the dump
      flash[:error] = "The backup was unsuccessful. Please try again."
    end
	end
	
	def restore
	  # upload and save the file
    @import = Import.new(params[:import])
    @import.save
    
	  success = system "/usr/local/mysql/bin/mysql -u root call_log_development < #{@import.csv.path}"
	  
	  if success
	    flash[:notice] = "The restore was successful."
	    @import.destroy
    else
      flash[:error] = "Failed to restore. Make sure the file is the correct format and try again."
      @import.destroy
      render :action => "index"
    end
    redirect_to staffs_url
	end



#-------------------------- Private helper methods ----------------------------------

  private

    # Read a csv file into a 2-d array.
		#
		#	@param path_to_csv - path to the parsed file
		# @return lines - array of each line in the file
		#
    def parse_csv_file(path_to_csv)
      lines = []
      FasterCSV.foreach(path_to_csv) do |row|
        lines << row
      end
      lines
    end

    # add a person to the database
		#
		# @param line - array containing person info
		#
  	def add_person(line)
      
      # set up the params hash
      params = Hash.new
      params[:staff] = Hash.new
      params[:staff][:staff_id] = line[@row_positions[:staff_id]]
      params[:staff][:first_name] = line[@row_positions[:first_name]]
      params[:staff][:last_name] = line[@row_positions[:last_name]]
      params[:staff][:nickname] = line[@row_positions[:nickname]]
      params[:staff][:address] = line[@row_positions[:address]]
      params[:staff][:city] = line[@row_positions[:city]]
      params[:staff][:state] = line[@row_positions[:state]]
      params[:staff][:zip] = line[@row_positions[:zip]]
      params[:staff][:gender] = line[@row_positions[:gender]]
      params[:staff][:doh] = line[@row_positions[:doh]]
      params[:staff][:cell_number] = line[@row_positions[:cell_number]]
      params[:staff][:home_number] = line[@row_positions[:home_number]]
      params[:staff][:agency_staff] = line[@row_positions[:agency_staff]]
      
      # create and save the new staff member to the db
      person = Staff.new(params[:staff])
      person.save
  	end
end
