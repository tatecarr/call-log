class HousesController < ApplicationController
  auto_complete_for :house, :name
  
  # GET /houses
  # GET /houses.xml
  def index
    puts params;
    # to allow for searching with autocomplete on house name
    #params[:search][:house_name_like] = params[:house][:name] unless params[:house].nil?
    
    
    @search = House.find_by_name("Gordon College")#.search(:all)#params[:search])
    @houses = @search

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @houses }
    end
  end

  # GET /houses/1
  # GET /houses/1.xml
  def show
    @house = House.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @house }
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
    @house = House.new(params[:house])

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
