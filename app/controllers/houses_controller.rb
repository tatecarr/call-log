class HousesController < ApplicationController
  auto_complete_for :house, :full_info
  
  # GET /houses
  # GET /houses.xml
  def index
    # to allow for searching with autocomplete on house name

    params[:search][:full_info_like] = params[:house][:full_info] unless params[:house].nil?
    
    # catch report form submissions
    unless params[:bu_code_equals].nil?
      params[:search] = Hash.new
      params[:search][:bu_code_equals] = [params[:bu_code_equals]]
    end
    
    @search = House.search(params[:search])
    @houses = @search.all

    if @houses.length == 1 && params[:search][:bu_code_equals].nil?
      
      redirect_to @houses[0]
      
    else
    
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @houses }
        format.pdf  { render :layout => false }
      end
      
    end
    
  end

  # GET /houses/1
  # GET /houses/1.xml
  def show
    @house = House.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @house }
      format.pdf { render :layout => false }
    end
  end

  # GET /houses/new
  # GET /houses/new.xml
  def new
    @house = House.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @house }
    end
  end

  # GET /houses/1/edit
  def edit
    @house = House.find(params[:id])
  end

  # POST /houses
  # POST /houses.xml
  def create
    params[:house][:full_info] = params[:house][:name] + " (" + params[:house][:bu_code] + ")"
    @house = House.new(params[:house])
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

  # PUT /houses/1
  # PUT /houses/1.xml
  def update
    @house = House.find(params[:id])

    respond_to do |format|
      if @house.update_attributes(params[:house])
        flash[:notice] = 'House was successfully updated.'
        format.html { redirect_to(@house) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @house.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /houses/1
  # DELETE /houses/1.xml
  def destroy
    @house = House.find(params[:id])
    @house.destroy

    respond_to do |format|
      format.html { redirect_to(houses_url) }
      format.xml  { head :ok }
    end
  end
  
  def manage_staff
    @house = House.find(params[:id])
    
    
    
    
  end
  
end
