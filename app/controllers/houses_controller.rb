class HousesController < ApplicationController
  
  # wysiwyg editor setup for tiny_mce plugin
  uses_tiny_mce :options => {
                                :theme => 'advanced',
                                :skin => "o2k7",
                                :skin_variant => "silver",
                                :plugins => %w{ table },
                                :theme_advanced_buttons3 => "tablecontrols",
                                :theme_advanced_resizing => true,
                                :theme_advanced_statusbar_location => "bottom",
                                :theme_advanced_toolbar_location => "top"
                              }
  
  # make sure the person is logged in
  before_filter :login_required
  
#------------------- Creates AJAX methods for autocompleting forms -----------------
  
  auto_complete_for :house, :full_info
  auto_complete_for :staff, :full_name
  
#--------- Action for displaying a searchable list of all houses in the DB ---------

  def index
    create_pdf = false

    #-------------------------------------------------------------------------------
    # To allow for searching (with autocomplete) on house name
    # full_info_like is a searchlogic formatted parameter, which allows the
    # searching.  For more info on searchlogic, see the link below.
    #
    # http://github.com/binarylogic/searchlogic/blob/master/README.rdoc
    #-------------------------------------------------------------------------------
    params[:search][:full_info_like] = params[:house][:full_info] unless params[:house].nil?
    
    # catch report form submissions.  used by the prawn plugin for generating pdfs.
    unless params[:bu_code_equals].nil?
      params[:search] = Hash.new
      params[:search][:bu_code_equals] = [params[:bu_code_equals]]
      create_pdf = true
    end
    
    #-------------------------------------------------------------------------------
    # If a search has been exectued, the House.search will return return the results.
    # The search string is executed against the full_info column in the House table,
    # which is defined above when params[:search][:full_info_like] is created.
    #-------------------------------------------------------------------------------
    @search = House.search(params[:search])
    @houses = @search.all

    #-------------------------------------------------------------------------------
    # When only one house is returned in a search, redirect directly to that house's
    # page instead of showing the search results.
    #-------------------------------------------------------------------------------
    ### TODO gives error if one house is in the database...can't evaluate params[:search]...also must fix this problem while adding houses
    ### I think I fixed this, but needs a little testing with adding/removing houses, searching, and pdf stuff when that gets implemented.

    # if params[:search]
    #       
    #       if @houses.length == 1 && params[:search][:bu_code_equals].nil?
    #         redirect_to @houses[0]
    #       end
    #     
    #     # Else display the page accordingly depending on the type of request.
    #     else 
      
    # makes it so that the first time the page is viewed, the houses are ordered by bu_code.
    # then the user can click a column heading and use the search to manipulate the list and order.
    if params[:search].nil? or create_pdf
      @houses = @houses.sort_by(&:name)
    end
    
    # Html and .pdf will be the formats used most of the time.
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @houses }
      format.pdf do
        render  :pdf => "House Report",
                :template => "houses/index.pdf.erb",
                :stylesheets => ["application", "prince_house", "scaffold"],
                :layout => "pdf"
      end
    end
  end

#----------------------- Action for displaying house pages -------------------------

  def show
    
    @house = House.find(params[:id])

    # Does a SQL select statement for all the staff that work at this house.  We want
    # to do this because we want to sort the staff first by their :sort_order which
    # is dependent on the @house_position_list in the application_controller, and then
    # secondly by the staffs' first name.
    @ordered_full_time_staff = HouseStaff.find_by_sql("select house_staffs.* from house_staffs join staffs on house_staffs.staff_id = staffs.staff_id where house_staffs.bu_code = #{@house.bu_code} and house_staffs.position_type = 'Full Time Staff' order by house_staffs.sort_order, staffs.first_name")
    @ordered_relief_staff = HouseStaff.find_by_sql("select house_staffs.* from house_staffs join staffs on house_staffs.staff_id = staffs.staff_id where house_staffs.bu_code = #{@house.bu_code} and house_staffs.position_type = 'Relief Staff' order by house_staffs.sort_order, staffs.first_name")
    @ordered_overtime_staff = HouseStaff.find_by_sql("select house_staffs.* from house_staffs join staffs on house_staffs.staff_id = staffs.staff_id where house_staffs.bu_code = #{@house.bu_code} and house_staffs.position_type = 'Overtime Staff' order by house_staffs.sort_order, staffs.first_name")

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @house }
      format.pdf do
        render  :pdf => "House Report",
                :template => "houses/show.pdf.erb",
                :stylesheets => ["application", "prince_house", "scaffold"],
                :layout => "pdf"
      end
    end
  end

#----------------------- Action for creating a new house ---------------------------

  def new
    
    #-------------------------------------------------------------------------------
    # Creates a new House object, which through object-relational mapping, will
    # be saved into the House table in the database.
    #-------------------------------------------------------------------------------
    @house = House.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @house }
    end
  end

#------------------------- Action for editing a house ------------------------------

  def edit
    @house = House.find(params[:id])
  end

#----------------- Action called when a new house is created -----------------------

  def create

    #-------------------------------------------------------------------------------    
    # Concatenate the house name and bu_code to add to full_info column to
    # facilitate easier autocomplete and searching.
    #-------------------------------------------------------------------------------
    params[:house][:full_info] = params[:house][:name] + " (" + params[:house][:bu_code] + ")"
    @house = House.new(params[:house])

    #-------------------------------------------------------------------------------    
    # Set the House's :bu_code which is the primary key and rails was not
    # automatically entering in the database.
    #-------------------------------------------------------------------------------
    @house.bu_code = params[:house][:bu_code]

    respond_to do |format|
      if @house.save
        flash[:notice] = 'House was successfully created.'
        format.html { redirect_to(@house) }
        format.xml  { render :xml => @house, :status => :created, :location => @house }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @house.errors, :status => :unprocessable_entity }
      end
    end
  end

#---------------- Action called when updating a house that exists ------------------

  def update
    @house = House.find(params[:id])
    
    respond_to do |format|
      if @house.update_attributes(params[:house])
        @house.full_info = @house.name + " (" + @house.bu_code.to_s + ")"
        @house.save
        flash[:notice] = 'House was successfully updated.'
        format.html { redirect_to(@house) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @house.errors, :status => :unprocessable_entity }
      end
    end
  end

#---------------- Action called when deleting a house from the DB ------------------

  def destroy
    @house = House.find(params[:id])
    @house.destroy

    respond_to do |format|
      format.html { redirect_to(houses_url) }
      format.xml  { head :ok }
    end
  end
end
