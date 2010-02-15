class StaffsController < ApplicationController
  auto_complete_for :staff, :full_name
  auto_complete_for :staff, :home_number
  auto_complete_for :staff, :cell_number
  
  # GET /staffs
  # GET /staffs.xml
  def index

    # The options for number of results per page.
    @number_per_page_options = [["25", "0"], ["50", "1"], ["75", "2"], ["100", "3"]]
    @number_per_page = params[:number_per_page] || 0
    @selected_number = @number_per_page_options[@number_per_page.to_i][0]
    
    # to allow for searching with auto complete on last name
    params[:search][:full_name_like] = params[:staff][:full_name] unless params[:staff].nil?
    params[:search][:home_number_like] = params[:staff][:home_number] unless params[:staff].nil?
    params[:search][:cell_number_like] = params[:staff][:cell_number] unless params[:staff].nil?
    
    #TODO - WE SHOULD SAVE THE SEARCH PARAMS SO THAT THE FIELDS ARE POPULATED WITH THEM WHEN
    #THE PAGE REFRESHES.  I DID THE RESULTS PER PAGE THIS WAY, BUT WE'D NEED TO DO IT FOR
    #THE OTHER FIELDS AS WELL.
    
    @search = Staff.search(params[:search])
    @staffs = @search.paginate :per_page => @selected_number, :page => params[:page]
    
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
  end

  # POST /staffs
  # POST /staffs.xml
  def create
    @staff = Staff.new(params[:staff])

    respond_to do |format|
      if @staff.save
        flash[:notice] = 'Staff was successfully created.'
        format.html { redirect_to(@staff) }
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
      format.html { redirect_to(staffs_url) }
      format.xml  { head :ok }
    end
  end
end
