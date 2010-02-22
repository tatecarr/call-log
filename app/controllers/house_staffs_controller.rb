class HouseStaffsController < ApplicationController
  before_filter :login_required

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
    @house_staff = @house.house_staffs.create!({ :bu_code => @house.bu_code, :staff_id => (/\d+/.match(params[:staff][:full_name])).to_s, :position_name => params[:house_staff][:position_name] })

    respond_to do |format|
      format.html { redirect_to @house }
      format.js
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
