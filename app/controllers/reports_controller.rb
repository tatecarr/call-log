#-----------------------------------------------------------------------------------
# reports_controller.rb
#
# Handles all actions and logic for the report creation of the call log system
#
# Written By: Ben Vogelzang 1/28/10
#
#-----------------------------------------------------------------------------------

class ReportsController < ApplicationController
  # make sure the person is logged in
  before_filter :login_required
  
  # logs the person out after 60 minutes
  session_times_out_in SystemSetting.first.session_timeout.minutes, :after_timeout => :log_them_out

  # the only page in the reports section. Print all the reports from here
  def index
    @houses = House.all.sort_by(&:name)
    @staff = Staff.all
  end
  
  # for all the predefined staff reports
  def predefined_report
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
  
  # for the house reports
  def house_report
   
    # catch report form submissions.  used by the prawn plugin for generating pdfs.
    params[:search] = Hash.new
    unless params[:bu_code_equals].nil?
        params[:search][:bu_code_equals] = [params[:bu_code_equals]]
    end
    
    @search = House.search(params[:search])
    @houses = @search.all
    
    # If only one house is being printed, the pdf file name will be the name of the house
    # else it will be "Houses Report".  Previously it was always "House Report".
    #fileName = @houses.count == 1 ? @houses[0].name : "Houses Report"
    
    # Html and .pdf will be the formats used most of the time.
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @houses }
      format.pdf do
        render  :pdf => "Houses Report",
                :template => "houses/index.pdf.erb",
                :stylesheets => ["application", "prince_house", "scaffold"],
                :layout => "pdf"
      end
    end
  end

end