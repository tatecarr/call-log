#-----------------------------------------------------------------------------------
# admin_controller.rb
#
# Handles all actions and logic for the admin section of the call log
#
# Written By: Ben Vogelzang 1/28/10
#
#-----------------------------------------------------------------------------------

class AdminController < ApplicationController

  before_filter :admin_required
  auto_complete_for :house, :full_info
  
  def auto_complete_for_house_full_info
    
    leg = params[:house].keys[0] # get index as its always only one at a time

    auto_complete_responder_for_full_info params[:house][leg][:full_info]
    
  end
  
#--------------------- Action for creating a UserHouse Assoc. ----------------------

  def create
    
    # Create a UserHouse Association with the passed params.
    @user_house = UserHouse.new
    
    # need user_id below, and @user_house.user_id was nil until the object gets saved I think
    # because a nil error was being given when I directly assigned params[:user_id] to the
    # @user_house.user_id and then used the variable's attr in the find below.
    user_id = params[:user_id]

    #-------------------------------------------------------------------------------
    # The :full_info of the house is passed to allow for easier searching, so using
    # that information, the associated house is found, and its :bu_code is added.
    #-------------------------------------------------------------------------------
    
    # set full info to whatever was passed in the :full_info of the params
    full_info = params[:house][user_id][:full_info].strip
    
    # set bu_code to the set of digits in the passed parameter
    bu_code = (/\d+/.match(full_info)).to_s
    
    # try and find the house this user having added based on the bu_code
    @house = House.find_by_bu_code(bu_code)
    
    # if a house was not found, we will try and match the full info based on what was passed
    if !@house
      
      # set bu_code to nothing since it obviously was not a valid bu_code (no hosue found)
      bu_code = ""
      
      # display message when the user doesn't provide a search term.
      if full_info == ""
        
        message = "<br/>Please enter a search term.<br/><br/>"
        
      # else they have provided a search term
      else
        
        # for the mysql format when executing a 'LIKE' query
        full_info = "%" + full_info + "%"
        
        # if the returned array is less than size one, nothing was found. set message accordingly.
        if (@house = House.find(:all, :conditions => ["full_info like ?", full_info])).length < 1
          
          message = "<br/>No house found.  Please refine search.<br/><br/>"
          
        # else if length is less than 2, meaning length = 1, then we want the bu_code
        elsif @house.length < 2
          
          bu_code = @house[0].bu_code
          
        # else more than one result was found and the user needs to refine their search.
        else
          
          message = "<br/>Multiple staff found.  Please refine search.<br/><br/>"
          
        end
      end
    end
    
    # if bu_code is still blank, no house has been found, and we'll update the message div
    # with whatever reason no house has been found, which will have been set above.
    if bu_code.to_s.blank?
      
      # put the message in the correct div to display to the user.
      render :update do |page|
        page["add_house_message_#{user_id}"].replace_html message
      end
      
    # else if a house was found, but the found house is already assigned to the user, display the message below.
    elsif !UserHouse.find(:all, :conditions => ["user_id = ? AND bu_code = ?", user_id, bu_code]).empty?
      
      message = "<br/>The house identified is already assigned to this user.<br/><br/>"
      
      render :update do |page|
        page["add_house_message_#{user_id}"].replace_html message
      end
    
    # else a valid house has been found, so add the record to the UserHouse table.          
    else
      
      # clear any previous message if a bad search had been run.
      message = ""
      
      # set the UserHouse attributes, the user_id was passed as a param, and the bu_code was found above.
      @user_house.bu_code = bu_code
      @user_house.user_id = user_id

      # Save the association to the DB
      @user_house.save

      # Rails specific AJAX commands
      render :update do |page|
      
        #-------------------------------------------------------------------------------      
        # Format is   page.insert_html  [where in div], [div id to insert into], 
        #                               [name of partial], [values to pass to partial]
        #
        # Adds a user_house partial to the specified div at the bottom, the partial contains the html
        # necessary for displaying the values in the association, and the @user_house created above
        # contains the information of the new association.
        #
        # This is done in the background, so the list is updated and the page doesn't reload.
        #-------------------------------------------------------------------------------
        page.insert_html :bottom, "houses_list_#{@user_house.user_id}", :partial => "user_house", :collection => [@user_house]
      
        # Causes the new parital to be highlighted for a short period
        page.visual_effect :highlight, "houses_list_#{@user_house.user_id}"
      
        # Clears the form where the user_house information was entered.
        page["form_#{@user_house.user_id}"].reset
        
        # shows/clears a message depending on if a house was added successfully or not.
        page["add_house_message_#{user_id}"].replace_html message
      end
    end
  end

#--------------------- Action for deleting a UserHouse Assoc. ----------------------
  
  def remove_user_house
    
    # finds the user_house association table record.  it takes the first one, but there should.
    @user_house = UserHouse.find(:all, :conditions => ["user_id = ? AND bu_code = ?", params[:user_id], params[:bu_code]])[0]
    
    # save the id of the record, because we'll need it after we delete the record.
    @user_house_id = @user_house.id
    
    # delete the record for this user_house association.
    @user_house.delete
		
		# ajax, hides the div that displayed this relationship, which no longer exists.
		render :update do |page|
			page.visual_effect :fade, "user_house_#{@user_house_id}", :duration => 0.25
		end
  end
  
  # non-ajax way of removing assoc.  but not being used at this point I don't think.
  def destroy
    @user_house = UserHouse.find(params[:id])
    @user_house.destroy
    
    redirect_to :action => "index"

  end

#-------------------------- Actions for displaying pages ---------------------------
 
  def index
    @user = User.new
    @users = User.all
    @user_house = UserHouse.new
  end
  
  def agency_staff
    @agency_staffs = Staff.find(:all, :conditions => ['agency_staff = ?', true])
  end
  
  def backup_restore
    @import = Import.new
  end
  
  def import_staff
    @import = Import.new
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
    
    # does the file have anything in it?
    if lines.empty?
      flash[:error] = "There was nothing in the file."
      redirect_to :action => "index" and return
    end
    
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
          add_person(line) unless line.empty?
      end
      
      # we don't need the file anymore so we can remove it
      @import.destroy
      
      flash[:notice] = "CSV data processing was successful."
      redirect_to staffs_url
    else
      
      flash[:error] = "The file did not contain any people. Please make sure there are people in the file."
      render :action => "index"
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
    success = system "mysqldump -u root #{config['database']} > call_log_backup_#{now}.sql"
    
    if success
      # if we were successful backing up the file, move it to a place where it can be downloaded
      moved = system "mv call_log_backup_#{now}.sql public/call_log_backup_#{now}.sql"
      send_file "public/call_log_backup_#{now}.sql", :type => "text/plain" if moved
    else
      # something went wrong with the dump
      flash[:error] = "The backup was unsuccessful. Please try again."
      redirect_to backup_restore_path
    end
	end
	
	def restore
	  # upload and save the file
    @import = Import.new(params[:import])
    @import.save
    
	  success = system "mysql -u root call_log_development < #{@import.csv.path}"
	  
	  @import.destroy
	  
	  if success
	    flash[:notice] = "The restore was successful."
	    @import.destroy
    else
      flash[:error] = "Failed to restore. Make sure the file is the correct format and try again."
      @import.destroy
      render :action => "index"
    end
    redirect_to backup_restore_path
	end

#-------------------------- Private helper methods ----------------------------------

  private
  
  
    def auto_complete_responder_for_full_info(value)
        
      param = '%' + value.downcase + '%' 
      find_options= {
        :conditions => [ 'LOWER(full_info) LIKE ?', param ],
        :order => 'full_info ASC',
        :limit => 10
      }
      @houses = House.find(:all, find_options)
      render :partial => 'house_full_info'

    end

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
      params[:staff][:full_name] = params[:staff][:first_name] + " " + params[:staff][:last_name] + " (" + params[:staff][:staff_id] +")"
      params[:staff][:nickname] = line[@row_positions[:nickname]]
      params[:staff][:address] = line[@row_positions[:address]]
      params[:staff][:city] = line[@row_positions[:city]]
      params[:staff][:state] = line[@row_positions[:state]]
      params[:staff][:zip] = line[@row_positions[:zip]]
      params[:staff][:gender] = line[@row_positions[:gender]]
      params[:staff][:doh] = line[@row_positions[:doh]]
      params[:staff][:cell_number] = line[@row_positions[:cell_number]]
      params[:staff][:home_number] = line[@row_positions[:home_number]]
      params[:staff][:agency_staff] = false
      
      # Conditions to check if based on their certifications the staff earns $9.65 | $10.19
      # We don't have the format of that info at this time, so it'll be hardcoded $9.65 for now.
      params[:staff][:payrate] = "$9.65"
      
      # create and save the new staff member to the db
      person = Staff.new(params[:staff])
      person.save
      
      # want to create a model for holding their info too - there are 4 fields
      # that hold info about each staff that we don't want to be overwritten
      # after each import, so they are a separate model linking to staff with
      # the coresponding staff_id.  if the imported staff doesn't have a record
      # in this table, create it, otherwise they've been imported before.
      #
      # if StaffInfo not found for this staff_id, create one.  otherwise do nothing.
      if StaffInfo.find_by_staff_id(params[:staff][:staff_id]).nil?
        staff_info = StaffInfo.new
        # set the record's staff_id to that of the staff member being created.
        staff_info.staff_id = params[:staff][:staff_id]
        staff_info.experience_prefs = "Click here to add experience and preferences info."
        staff_info.skills_limits = "Click here to add skills and limits info."
        staff_info.schedule_availability = "Click here to add schedule and availability info."
        staff_info.contact_notes = "Click here to add conact info and other notes."
        staff_info.save
      end
      
  	end
end
