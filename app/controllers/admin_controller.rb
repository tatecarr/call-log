#-----------------------------------------------------------------------------------
# admin_controller.rb
#
# Handles all actions and logic for the admin section of the call log system
#
# Written By: Ben Vogelzang 1/28/10
#
#-----------------------------------------------------------------------------------

class AdminController < ApplicationController

  # check to make sure somebody has required access level for all of these
  before_filter :admin_required
  
  # logs the person out after 60 minutes
  session_times_out_in SystemSetting.first.session_timeout.minutes, :after_timeout => :log_them_out
  
  # auto complete for some of the actions
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
 
  # index page of the admin section
  def index
    @user = User.new
    @users = User.all
    @user_house = UserHouse.new
  end
  
  # agency staff page of the admin section
  def agency_staff
    @agency_staffs = Staff.find(:all, :conditions => ['agency_staff = ?', true])
  end
  
  # backup restore page
  def backup_restore
    @import = Import.new
  end
  
  # staff import page
  def import_staff
    @import = Import.new
  end
  
  def edit_session_timeout
    @system_setting = SystemSetting.new
  end
  
  def update_session_timeout
    @system_setting = SystemSetting.first
    @system_setting.session_timeout = params[:system_setting][:session_timeout].to_i < 10 ? 10 : params[:system_setting][:session_timeout]
    if @system_setting.save
      flash[:notice] = "Session timeout length was successfully changed."
    else
      flash[:error] = "Failed to change session timeout length."
    end
    redirect_to edit_session_timeout_path
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
    
    # Exit if no file was selected
    unless @import.save
      # remove the file and show error
      @import.destroy
      flash[:error] = "No File was selected"
      redirect_to :action => "import_staff" and return
    end
    

    # Exit if the file is not a .csv file
    unless @import.csv.path.match(/\.csv$/)
      # remove the file and show error
      @import.destroy
      flash[:error] = "The file you are trying to upload is not a .csv file"
      redirect_to :action => "import_staff" and return
    end

    # read the csv file into a 2-d array
    lines = parse_csv_file(@import.csv.path)

    # does the file have anything in it?
    if lines.empty?
      # remove the file and show error
      @import.destroy
      flash[:error] = "There was nothing in the file."
      redirect_to :action => "import_staff" and return
    end
    
    #replace the first line with cleaner headings...this could result in nasty data, 
    #but the user should see that after upload finishes
    lines[0] = ["last_name", "first_name", "doh", "gender", "home_number", "phone_number", 
                "work_number", "course", "renewal_date", "email_address", "address", 
                "city", "org_level", "employee_number", "employee_status"]

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

      # delete all courses that ARE NOT for agency staff
      remove_courses_except_non_res

      # delete all the staff that ARE NOT agency staff
      Staff.delete_all(["agency_staff = ?", false])
      
      already_added = false
      prev_id = -1
      # step through the file and add a person for each line
      lines.each do |line|
        #makes sure that there is 15 elements on the line (first, last, address, etc.)
        #otherwise the line is blank or invalid
        #line.empty? always returns false.  line is an array, and may be length == 0, but won't be empty.
        if line.length == 15
          
          already_added = prev_id == line[@row_positions[:employee_number]].to_i ? true : false
          
          unless already_added
            add_person(line)
            prev_id = line[@row_positions[:employee_number]].to_i
          end
          add_course(line)
          
        end
      end

      # update the pay rate for relief staff
      update_pay_rate
      
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
    success = system "mysqldump -u #{config['username']} -p#{config['password']} #{config['database']} > call_log_backup_#{now}.sql"
    
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
	
	# restore from a database backup file
	def restore
	  # upload and save the file
    @import = Import.new(params[:import])
    
    # Exit if no file was selected
    unless @import.save
      # remove the file and show error
      @import.destroy
      flash[:error] = "No File was selected"
      redirect_to :action => "backup_restore" and return
    end
    
    # Exit if the file is not a .sql file
    unless @import.csv.path.match(/\.sql$/)
      # remove the file and show error
      @import.destroy
      flash[:error] = "The file you are trying to upload is not a .sql file"
      redirect_to :action => "backup_restore" and return
    end
    
    file = File.open(@import.csv.path, 'r')
    lines = file.readlines
    file.close()
    if lines.empty?
      # remove the file and show error
      @import.destroy
      flash[:error] = "The selected file was empty"
      redirect_to :action => "backup_restore" and return
    end    
    
    require 'erb'
    require 'yaml'

    # make sure that we're set up to connnect to a database
    unless config = YAML::load(ERB.new(IO.read(RAILS_ROOT + "/config/database.yml")).result)[RAILS_ENV]
      abort "No database is configured for the environment '#{RAILS_ENV}'"
    end
    
	  success = system "mysql -u #{config['username']} -p#{config['password']} #{config['database']} < #{@import.csv.path}"
	  
	  if success
	    flash[:notice] = "The restore was successful."
	    @import.destroy
	    redirect_to backup_restore_path
    else
      flash[:error] = "Failed to restore. Make sure the file contains the correct MySQL syntax."
      @import.destroy
      redirect_to backup_restore_path
    end
	end

#-------------------------- Private helper methods ----------------------------------

  private
  
    # allows for multiple auto complete forms on the same page
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
      theFile = File.open(path_to_csv, "r")
      lines = []
    
      if theFile
        theFile.readlines.each do |line|
          
          # ne-arc's input file was within quotation marks...   not anymore...thanks guys.
          #
          # remove leading quotation mark.
          line.sub!(/\A"/, "")
          
          # remove second quote, which is around the "last, fist"
          line.sub!(/\s*"\s*/, "")
          
          # remove trailing quotation mark.
          #line.sub!(/"\s*\Z/, "")
          
          # if any of the comma delimeted elements contains a comma, their system surrounds
          # that element with quotes.
          
          # So if the line matches "..anything.."
          if line =~ /".*"/
            
            # gsub applies the substitute for each match in the string.  So we remove the commas
            # and then the double quotes.
            line.gsub!(/".*"/, line.match(/".*"/)[0].gsub(/,/, "").gsub(/"/, ""))
            
          end
          
          # convert the comma delimeted string into an array with each comma delimted substring
          # being one of the elements.
          lines << line.split(",")
          
        end
        
      else
        flash[:error] = "Was not able to read file. Please try again with another file."
        redirect_to :action => "import_staff" and return
      end  
      theFile.close()
      lines
    end

    # add a person to the database
		#
		# @param line - array containing person info
		#
  	def add_person(line)
      
      # set up the params hash
      staff = Staff.new
      staff.staff_id = line[@row_positions[:employee_number]].to_i
      staff.first_name = line[@row_positions[:first_name]].match(/[A-Za-z0-9'-.\s]*/).to_s.strip
      staff.last_name = line[@row_positions[:last_name]].match(/[A-Za-z0-9'-.\s]*/).to_s.strip
      staff.full_name = staff.first_name + " " + staff.last_name + " (" + line[@row_positions[:employee_number]].match(/\d+/)[0] +")"
      staff.address = line[@row_positions[:address]]
      staff.city = line[@row_positions[:city]]
      staff.gender = line[@row_positions[:gender]]
      staff.doh = line[@row_positions[:doh]]
      staff.email = line[@row_positions[:email_address]]
      staff.cell_number = line[@row_positions[:phone_number]]
      staff.home_number = line[@row_positions[:home_number]]
      staff.work_number = line[@row_positions[:work_number]]
      staff.org_level = line[@row_positions[:org_level]]
      staff.status = line[@row_positions[:employee_status]]
      staff.agency_staff = false
      
      # Conditions to check if based on their certifications the staff earns $9.65 | $10.19
      # We don't have the format of that info at this time, so it'll be hardcoded $9.65 for now.
      staff.payrate = staff.org_level == 299 ? 9.65 : 0.00
      
      # create and save the new staff member to the db
      staff.save
      
      # want to create a model for holding their info too - there are 4 fields
      # that hold info about each staff that we don't want to be overwritten
      # after each import, so they are a separate model linking to staff with
      # the coresponding staff_id.  if the imported staff doesn't have a record
      # in this table, create it, otherwise they've been imported before.
      #
      # if StaffInfo not found for this staff_id, create one.  otherwise do nothing.
      if StaffInfo.find_by_staff_id(staff.staff_id).nil?
        staff_info = StaffInfo.new
        # set the record's staff_id to that of the staff member being created.
        staff_info.staff_id = staff.staff_id
        staff_info.experience_prefs = "Click here to add experience and preferences info."
        staff_info.skills_limits = "Click here to add skills and limits info."
        staff_info.schedule_availability = "Click here to add schedule and availability info."
        staff_info.contact_notes = "Click here to add conact info and other notes."
        staff_info.include_in_reports = 0
        staff_info.save
      end
      
  	end
  	
  	# add a course to a staff member
  	def add_course(line)
  	  course = Course.new
  	  course.staff_id = line[@row_positions[:employee_number]].to_i
  	  course.name = line[@row_positions[:course]]
      course.renewal_date = line[@row_positions[:renewal_date]]
  	  unless course.name.empty? and course.renewal_date.nil?
  	    course.name = "Unknown" if course.name.empty?
  	    course.save
  	  end
  	end
  	
  	# runs the mysql to update the payrate of certain staff members
  	def update_pay_rate
  	  ActiveRecord::Base.connection.execute("
  	  update staffs
            set staffs.payrate = 10.19
            where staffs.staff_id in (
              select x.staff_id

              from (select staffs.staff_id, count(staffs.staff_id) as number
                      from staffs join courses on staffs.staff_id = courses.staff_id
                      where  
                        ((courses.name like '%CPR%' and (courses.name like '%Adult%' or courses.name like '%American Heart Asso%')) 
                        or courses.name like '%MAPS%' 
                        or courses.name like '%First Aid%')
                      and DATEDIFF(courses.renewal_date, NOW()) > 0 
                      group by staffs.staff_id) as x

              where x.number > 2) AND staffs.org_level = 299")
  	end
  	
  	# remove all courses except non-res staff.
  	def remove_courses_except_non_res
  	  ActiveRecord::Base.connection.execute("
  	  
  	  delete from courses 
  	  where courses.staff_id not in 
  	    (select staff_id 
  	    from staffs 
  	    where agency_staff = true)
  	    
  	  ")

  	end
end
