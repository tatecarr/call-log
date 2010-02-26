class StaffsController < ApplicationController
  before_filter :login_required
  auto_complete_for :staff, :full_name
  auto_complete_for :staff, :home_number
  auto_complete_for :staff, :cell_number
  
  in_place_edit_for :staff_info, :experience_prefs
  in_place_edit_for :staff_info, :skills_limits
  in_place_edit_for :staff_info, :schedule_availability
  in_place_edit_for :staff_info, :contact_notes
  
  # GET /staffs
  # GET /staffs.xml
  def index

    #TODO, LIST HOW MANY STAFF ARE IN THE LIST.  BOTH WHEN A SEARCH IS EXECUTED OR OTHERWISE

    # The options for number of results per page.
    @number_per_page_options = [["25", "0"], ["50", "1"], ["75", "2"], ["100", "3"]]
    @number_per_page = params[:number_per_page] || 0
    @selected_number = @number_per_page_options[@number_per_page.to_i][0]
    
    # Save search terms so the fields can be populated with them after a search instead of being cleared.
    @full_name = params[:staff][:full_name] unless params[:staff].nil?
    @home_number = params[:staff][:home_number] unless params[:staff].nil?
    @cell_number = params[:staff][:cell_number] unless params[:staff].nil?
    
    # to allow for searching with auto complete on last name
    params[:search][:full_name_like] = @full_name unless params[:staff].nil?
    params[:search][:home_number_like] = @home_number unless params[:staff].nil?
    params[:search][:cell_number_like] = @cell_number unless params[:staff].nil?
    
    @search = Staff.search(params[:search])
    
    # this makes it so that on the first load of the page, when params[:search] is nil, the call-log
    # is ordered by last_name.  it had been doing it by id (not staff_id), so after every import, the
    # agency staff would all be listed first in the call log.  kinda undesirable I think.
    if params[:search]
      @staffs = @search.paginate :per_page => @selected_number, :page => params[:page]
    else
      @staffs = @search.sort_by(&:last_name).paginate :per_page => @selected_number, :page => params[:page]
    end
    
    if @staffs.length == 1
      
      redirect_to @staffs[0]
      
    else

      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @staffs }
      end
    end
  end

  # GET /staffs/1
  # GET /staffs/1.xml
  def show
    @staff = Staff.find(params[:id])
    @staff_info = StaffInfo.find_by_staff_id(@staff.staff_id)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @staff }
    end
  end

  # GET /staffs/new
  # GET /staffs/new.xml
  def new
    @staff = Staff.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @staff }
    end
  end

  # GET /staffs/1/edit
  def edit
    @staff = Staff.find(params[:id])
    @staff_info = StaffInfo.find_by_staff_id(@staff.staff_id)
  end

  # POST /staffs
  # POST /staffs.xml
  def create
    @staff = Staff.new(params[:staff])
    @staff.full_name = params[:staff][:first_name] + " " + params[:staff][:last_name] + " (" + (Staff.last.id + 1).to_s + ")"
    
    # for agency staff the id and staff_id are the same.  it's also used for the staff_info record, so assigning to variable.
    staff_id = (Staff.last.id + 1).to_s
    @staff.id = staff_id
    @staff.staff_id = staff_id
    
    @staff_info = StaffInfo.new
    # set the record's staff_id to that of the staff member being created.
    @staff_info.staff_id = staff_id
    @staff_info.experience_prefs = "Click here to add experience and preferences info."
    @staff_info.skills_limits = "Click here to add skills and limits info."
    @staff_info.schedule_availability = "Click here to add schedule and availability info."
    @staff_info.contact_notes = "Click here to add conact info and other notes."
    
    respond_to do |format|
      if @staff.save && @staff_info.save
        flash[:notice] = 'Staff was successfully created.'
        format.html { redirect_to :controller => "admin" }
        format.xml  { render :xml => @staff, :status => :created, :location => @staff }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @staff.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /staffs/1
  # PUT /staffs/1.xml
  def update
    @staff = Staff.find(params[:id])

    respond_to do |format|
      if @staff.update_attributes(params[:staff])
        flash[:notice] = 'Staff was successfully updated.'
        format.html { redirect_to(@staff) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @staff.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /staffs/1
  # DELETE /staffs/1.xml
  def destroy
    @staff = Staff.find(params[:id])
    @staff.destroy

    respond_to do |format|
      format.html { redirect_to :controller => "admin" }
      format.xml  { head :ok }
    end
  end
end
