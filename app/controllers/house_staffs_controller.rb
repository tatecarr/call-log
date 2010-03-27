class HouseStaffsController < ApplicationController
  before_filter :login_required

  # NEED AN UPDATE SORT ORDER FOR ADMINS IF THE ORDER OF THE HOUSE STAFF POSITIONS CHANGE
  # THE ARRAY OF HOUSE POSITIONS IS IN THE APPLICATION_CONTROLLER AND SORT_ORDER IS BASED
  # UPON THE ORDER THERE.  BUT THE VALUE IS ENTERED INTO THE DATABASE AND WOULDN'T CHANGE
  # AUTOMATICALLY IF THE ARRAY ORDER/VALUES WERE CHANGED, SO A GLOBAL UPDATE ON HOUSE_STAFF
  # SORT_ORDER VALUES WOULD HAVE TO BE DONE.

#------------------- Action for showing all UserHouse Assocs. ----------------------

  # This action will never be called v1.0 code, but could be in the future.
  def index
    @house_staffs = HouseStaff.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @house_staffs }
    end
  end

#--------------------- Action for showing a UserHouse Assoc. -----------------------

  # This action will never be called v1.0 code, but could be in the future.
  def show
    @house_staff = HouseStaff.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @house_staff }
    end
  end

#------------------- Action for creating a new UserHouse Assoc. --------------------

  def new
    @house_staff = HouseStaff.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @house_staff }
    end
  end

  # GET /house_staffs/1/edit
  def edit
    @house_staff = HouseStaff.find(params[:id])
  end

#---------------- Action for creating a HouseStaff Assoc. in the DB ----------------

  def create
    
    # Find the house that the HouseStaff Assoc belongs to, its id is pass in the params
    @house = House.find(params[:house_id])
    
    # Get the :sort_order for this staff member by getting the index for the position
    # name in the @house_position_list which is in the application_controller.
    sort_order = house_position_list.index(params[:house_staff][:position_name])
    
    # House and HouseStaff have a one-to-many relationship.  So we call we want to
    # call @house.house_staffs.create and it will create a new house_staff association
    # record, while setting its foreign key to the :bu_code of the house it belongs
    # to, which was just found above.
    #
    # To provide easy searching, the parameters that are passed to create this association
    # are the :bu_code (:house_id), the :full_name of the staff member, and the :position_name.
    #
    # The :full_name is passed instead of the :staff_id because to allow autocomplete on
    # the staff member's name or their id, we want to search on a field of the staff model
    # which has both.  Which is why the :full_name column was added.  But we originally
    # designed the DB schema to take the :staff_id.
    #
    # So a regular expression is used to pull the :staff_id from the :full_name.
    #
    # An example of the :full_name is "John Smith (333)" where the :staff_id is in parenthesis.
    #
    # The regular expression /\d+/ will match a string of "one or more digits".  calling
    # the .match(string) method will return the matching substring in the provided string
    # parameter.  Which is then passed as a parameter to create the house_staffs.
    full_name = params[:staff][:full_name]
    
    staff_id = (/\d+/.match(full_name)).to_s

    if staff_id == "" || !(Staff.find_by_staff_id(staff_id))
      
      # in case an invalid staff_id was entered, clear it.
      staff_id = ""
      
      full_name_arr = full_name.split

      if full_name_arr

        if full_name_arr.length < 1
          # nothing was searched
          message = "<br/>Please enter a search term.<br/><br/>"

        elsif full_name_arr.length < 2
          # one search term was entered
          first_or_last_name = "%" + full_name_arr[0] + "%"
          
          # When only one search term entered, searches last name for a match first.
          #
          # when there is at least one match for last name, continue
          if (staff = Staff.find(:all, :conditions => ["last_name like ?", first_or_last_name])).length > 0
            
            # if there is only one result, set staff_id to that staff's id
            if staff.length < 2
              staff_id = staff[0].staff_id
              
            # else there is more than one match for last name, so display a message saying so
            else
              message = "<br/>Multiple staff found.  Please refine search.<br/><br/>"
            end
              
          elsif (staff = Staff.find(:all, :conditions => ["first_name like ?", first_or_last_name])).length > 0
            
            # if there is only one result, set staff_id to that staff's id
            if staff.length < 2
              staff_id = staff[0].staff_id
              
            # else there is more than one match for first name, so display a message saying so
            else
              message = "<br/>Multiple staff found.  Please refine search.<br/><br/>"
            end
            
          else
            # no staff matched the search
            message = "<br/>No staff found.  Please refine search.<br/><br/>"
          end
          
          
        # two or more search terms were entered. first two are set to first and last name.
        else
          first_name = "%" + full_name_arr[0] + "%"
          last_name = "%" + full_name_arr[1] + "%"
          
          # if at least one staff is returned whose first and last name a like the terms entered, continue
          if (staff = Staff.find(:all, :conditions => ["last_name like ? AND first_name like ?", last_name, first_name])).length > 0

            # if there is only one person returned, set the staff_id to that staff's id
            if staff.length < 2
              staff_id = staff[0].staff_id
              
            # more than one person was returned, display message saying so
            else
              message = "<br/>Multiple staff found.  Please refine search.<br/><br/>"
            end
          
          # no results were found for the 2+ terms entered, display a message saying so
          else
            message = "<br/>No staff found.  Please refine search.<br/><br/>"
            
          end
        end
      end
    end

    # if the staff_id is blank (no staff was found), display message as to why it is blank
    if staff_id.to_s.blank?
      render :update do |page|
        page["add_staff_message"].replace_html message
        page.visual_effect :highlight, "add_staff_message"
      end

    # if a valid staff_id is identified, but they are already assigned to the house, show message
    # if !.empty? then that means the staff is already assigned to the house because the array will have at least one element
    elsif !HouseStaff.find(:all, :conditions => ["staff_id = ? AND bu_code = ?", staff_id, @house.bu_code]).empty?
      
      message = "<br/>The staff identified is already assigned to this house.<br/>
                  Please remove them first to assign in a different position<br/>
                  or enter another staff member's name or id.<br/><br/>"
                  
      render :update do |page|
        page["add_staff_message"].replace_html message
        page.visual_effect :highlight, "add_staff_message"
      end

    # if a valid and unique staff_id was found through this ridiculous process, create a new house_staff record
    else
      
      # if there was an error message on a previous search, clear it.
      message = ""
      
      @house_staff = @house.house_staffs.new

      @house_staff.bu_code = @house.bu_code
      @house_staff.staff_id = staff_id
      @house_staff.position_name = params[:house_staff][:position_name]
      @house_staff.sort_order = sort_order
      @house_staff.position_type = params[:house_staff][:position_type]
      @house_staff.save                                                       

      render :update do |page|
        if @house_staff.position_type == "Full Time Staff"
          page["no_full_time_staff"].replace_html ""
        elsif @house_staff.position_type == "Relief Staff"
          page["no_relief_staff"].replace_html ""
        else
          page["no_overtime_staff"].replace_html ""
        end

        page["add_staff_message"].replace_html message
        page.insert_html :bottom, "#{@house_staff.position_type}", :partial => "house_staffs/house_staff"
        page.visual_effect :highlight, "#{@house_staff.position_type}"
        page[:new_house_staff].reset

      end
    end
    
  end

#--------------------- Action for updating a UserHouse Assoc. ----------------------

  def update
    @house_staff = HouseStaff.find(params[:id])

    respond_to do |format|
      if @house_staff.update_attributes(params[:house_staff])
        flash[:notice] = 'HouseStaff was successfully updated.'
        format.html { redirect_to(@house_staff) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @house_staff.errors, :status => :unprocessable_entity }
      end
    end
  end

#--------------------- Action for deleting a UserHouse Assoc. ----------------------

  # uses ajax to remove the HouseStaff assoc record
  def remove_house_staff
    
    # finds the user_house association table record.  it takes the first one, but there should.
    @house_staff = HouseStaff.find(:all, :conditions => ["staff_id = ? AND bu_code = ?", params[:staff_id], params[:bu_code]])[0]
    
    # save the id of the record, because we'll need it after we delete the record.
    @house_staff_id = @house_staff.id
    
    # delete the record for this user_house association.
    @house_staff.delete
		
		# ajax, hides the div that displayed this relationship, which no longer exists.
		render :update do |page|
			page.visual_effect :fade, "house_staff_#{@house_staff_id}", :duration => 0.25
		end
  end
  
  # non-ajax way of destroying the assoc
  def destroy
    @house_staff = HouseStaff.find(params[:id])
    @house_staff.destroy
    
    redirect_to House.find_by_bu_code(@house_staff.bu_code)

    #respond_to do |format|
    #  format.html { redirect_to(house_staffs_url) }
    #  format.xml  { head :ok }
    #end
  end
end
