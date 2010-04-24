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
    if params[:predefined_report].nil?
      
      # The options for number of results per page.
      @number_per_page_options = [["25", "0"], ["50", "1"], ["75", "2"], ["100", "3"]]
      @number_per_page = params[:number_per_page] || 0
      @selected_number = @number_per_page_options[@number_per_page.to_i][0]
    
      # Save search terms so the fields can be populated with them after a search instead of being cleared.
      @full_name = params[:staff][:full_name] unless params[:staff].nil?
      @home_number = params[:staff][:home_number] unless params[:staff].nil?
      @cell_number = params[:staff][:cell_number] unless params[:staff].nil?
      
      @staff = Staff.find_by_full_name(@full_name) unless @full_name.nil?
      
      # to allow for searching with auto complete on last name
      params[:search][:full_name_like] = @full_name unless params[:staff].nil?
      params[:search][:home_number_like] = @home_number unless params[:staff].nil?
      params[:search][:cell_number_like] = @cell_number unless params[:staff].nil?
      params[:search][:payrate_gt] = params[:search][:payrate_gt].to_f unless params[:search].nil? or params[:search][:payrate_gt].to_f == 0
      params[:search][:payrate_lt] = params[:search][:payrate_lt].to_f unless params[:search].nil? or params[:search][:payrate_lt].to_f == 0
      
      # default to relief staff
      unless params[:search]
        params[:search] = Hash.new
      end
      params[:search][:org_level_equals] = 299 if params[:org_level].nil?
      @org_level = true unless params[:org_level].nil?

      @search = Staff.search(params[:search])
    
      # this makes it so that on the first load of the page, when params[:search] is nil, the call-log
      # is ordered by last_name.  it had been doing it by id (not staff_id), so after every import, the
      # agency staff would all be listed first in the call log.  kinda undesirable I think.
      if params[:search]    
        
        # handles logic for searching certifications. Because it's another model and exclusion is implied we need to
        # use find_by_sql.     
        if params[:cpr] or params[:fa] or params[:mt]
          certification_array = []
          certification_array.push('First Aid') if params[:fa]
          certification_array.push('Adult CPR') if params[:cpr]
          certification_array.push('MAPS') if params[:mt]
          
          where_clause = certification_where_clause(certification_array)
          
          @certified = Staff.find_by_sql("select *
                                          from staffs
                                          where staff_id in (select staff_id

                                                            from (select staffs.staff_id, count(staffs.staff_id) as number
                                                                    from staffs join courses on staffs.staff_id = courses.staff_id
                                                                    where #{where_clause}
                                                                    and courses.renewal_date > now()
                                                                    group by staffs.staff_id) as x

                                                            where x.number = #{certification_array.length})")
          # get the difference between the search results and the certifications                                                  
          @staffs = @search & @certified
          @staffs = @staffs.paginate :per_page => @selected_number, :page => params[:page]
        else
          @staffs = @search.paginate :per_page => @selected_number, :page => params[:page]
        end
      else
        @staffs = @search.sort_by(&:last_name).paginate :per_page => @selected_number, :page => params[:page]
      end

      if !@staff.nil?
        redirect_to @staff and return
      elsif @staffs.length == 1 and params[:page].nil?
        redirect_to @staffs[0] and return
      end
    
    else
      case params[:predefined_report]
      when "relief"
        @staffs = Staff.find(:all, :conditions => ['agency_staff = ? and org_level = ?', false, 299], :order => "last_name")
      when "relief-with-full"
        @staffs = Staff.find_by_sql("select staffs.* 
                                    from staffs join staff_infos on staffs.staff_id = staff_infos.staff_id 
                                    where include_in_reports = true order by last_name")
      when "non-res"
        @staffs = Staff.find(:all, :conditions => ['agency_staff = ?', true], :order => "last_name")
      end
    end


    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @staffs }
      format.pdf do
        render  :pdf => "Staff Report",
                :template => "staffs/index.pdf.erb",
                :stylesheets => ["application", "prince", "scaffold"],
                :layout => "pdf"
      end
    end
  end
  
  def certification_where_clause(cert_arr)
    result = "("
    puts cert_arr
    cert_arr.each_with_index do |cert, i|
      result << " or " unless i == 0
      result << "(courses.name like '%CPR%' and (courses.name like '%Adult%' or courses.name like '%American Heart Asso%'))" if cert == "Adult CPR"
      result << "courses.name like '%MAPS%'" if cert == "MAPS"
      result << "courses.name like '%First Aid%'" if cert == "First Aid"
    end
    result << ")"
    result
  end

  # GET /staffs/1
  # GET /staffs/1.xml
  def show
    @staff = Staff.find(params[:id])
    @staff_info = StaffInfo.find_by_staff_id(@staff.staff_id)
    @staff_courses = @staff.courses
    
    @missing_courses = find_missing_courses(@staff_courses)
    
    @course_options = []
    for course in Course.find_by_sql("select distinct name from courses where name != '' order by name")
      @course_options << course.name
    end
    @course_options << "Adult CPR" if !@course_options.include?("Adult CPR")
    @course_options << "First Aid" if !@course_options.include?("First Aid")
    @course_options << "MAPS" if !@course_options.include?("MAPS")
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @staff }
      format.pdf { render :layout => false }
    end
  end
  
  def find_missing_courses(courses)
    missing_courses = ["First Aid", "Adult CPR", "MAPS"]
    
    current_courses = courses.map { |course|
      if course.name.match(/((Adult)|(American Heart Asso)) CPR/)
        "Adult CPR"
      elsif course.name.match(/MAPS/)
        "MAPS"
      elsif course.name.match(/First Aid/)
        "First Aid"
      end
    }
    
    missing_courses - current_courses
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
    staff_id = 1

    if Staff.last.nil?
      
      @staff.full_name = params[:staff][:first_name] + " " + params[:staff][:last_name] + " (1)"
      @staff.id = @staff.staff_id = 1
      
    else

      # for agency staff the id and staff_id are the same.  it's also used for the staff_info record, so assigning to variable.
      staff_id = (Staff.last.id + 1).to_s
      @staff.full_name = params[:staff][:first_name] + " " + params[:staff][:last_name] + " (" + staff_id + ")"
      @staff.id = @staff.staff_id = staff_id
      
    end
    
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
        format.html { redirect_to @staff }
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
      format.html { redirect_to non_res_staff_path }
      format.xml  { head :ok }
    end
  end
  
  def update_include_in_reports
    staff = Staff.find_by_staff_id(params[:staff_id])
    if params[:report_checked] == "report_checked"
      staff.staff_info.update_attributes(:include_in_reports => true)
      
      render :update do |page|
        page["include_message"].replace_html "Staff included."
        page.visual_effect :highlight, "include_message"
      end
      
    else
      staff.staff_info.update_attributes(:include_in_reports  => false)
      
      render :update do |page|
        page["include_message"].replace_html "Staff not included."
        page.visual_effect :highlight, "include_message"
      end
      
    end
  end  
  
  def add_course

    unless params[:course][:name].empty?
      @course = Course.new(params[:course])
      
      render :update do |page|
        
        if @course.save
          page.visual_effect :fade, "no_courses_message", :duration => 0.0
          page.insert_html :bottom, "courses_table", :partial => "staffs/staff_course"
          page.visual_effect :highlight, "courses_table"
          #page[:new_course].reset
        else
          page << "alert('Error adding course.  Please check to see that the course has not already been added to this staff.')"
        end
        
      end
    end

  end
  
  def remove_course
    
    Course.delete(params[:course_id])
    
    render :update do |page|
			page.visual_effect :fade, "course_#{params[:course_id]}", :duration => 0.25
		end
		    
  end
  
  def get_unformatted_text_prefs
    @staff = Staff.find_by_staff_id(params[:id])
    render :text => @staff.staff_info.experience_prefs(:source)
  end
  
  def get_unformatted_text_schedule
    @staff = Staff.find_by_staff_id(params[:id])
    render :text => @staff.staff_info.schedule_availability(:source)
  end
  
  def get_unformatted_text_skills
    @staff = Staff.find_by_staff_id(params[:id])
    render :text => @staff.staff_info.skills_limits(:source)
  end
  
  def get_unformatted_text_contact
    @staff = Staff.find_by_staff_id(params[:id])
    render :text => @staff.staff_info.contact_notes(:source)
  end
end
