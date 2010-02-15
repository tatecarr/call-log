class HousesController < ApplicationController
  
#------------------- Creates AJAX methods for autocompleting forms -----------------
  
  auto_complete_for :house, :full_info
  auto_complete_for :staff, :full_name
  
#--------- Action for displaying a searchable list of all houses in the DB ---------

  def index

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
    if @houses.length == 1 && params[:search][:bu_code_equals].nil?
      
      redirect_to @houses[0]
    
    # Else display the page accordingly depending on the type of request.
    else
      
      # Html and .pdf will be the formats used most of the time.
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @houses }
        format.pdf  { render :layout => false }
      end
    end
  end

#----------------------- Action for displaying house pages -------------------------

  def show
    @house = House.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @house }
      format.pdf { render :layout => false }
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
