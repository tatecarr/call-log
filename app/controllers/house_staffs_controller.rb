class HouseStaffsController < ApplicationController
  # GET /house_staffs
  # GET /house_staffs.xml
  def index
    @house_staffs = HouseStaff.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @house_staffs }
    end
  end

  # GET /house_staffs/1
  # GET /house_staffs/1.xml
  def show
    @house_staff = HouseStaff.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @house_staff }
    end
  end

  # GET /house_staffs/new
  # GET /house_staffs/new.xml
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

  # POST /house_staffs
  # POST /house_staffs.xml
  def create
    puts params[:house_id]
    @house = House.find(params[:house_id])
    @house_staff = @house.house_staffs.create!(params[:house_staff])
    respond_to do |format|
      format.html { redirect_to @house }
      format.js
    end

    #respond_to do |format|
    #  if @house_staff.save
    #    flash[:notice] = 'HouseStaff was successfully created.'
    #    format.html { redirect_to(@house_staff) }
    #    format.xml  { render :xml => @house_staff, :status => :created, :location => @house_staff }
    #  else
    #    format.html { render :action => "new" }
    #    format.xml  { render :xml => @house_staff.errors, :status => :unprocessable_entity }
    #  end
    #end
  end

  # PUT /house_staffs/1
  # PUT /house_staffs/1.xml
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

  # DELETE /house_staffs/1
  # DELETE /house_staffs/1.xml
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
