# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Authentication
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  helper_method :admin?
  helper_method :house_position_list
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  session_times_out_in 15.minutes, :after_timeout => :log_them_out
  
  protected
  
  def admin?
    current_user.role == "System-Admin"
  end
  

  def log_them_out
    flash[:error] = "You have been logged out due to inactivity. Please log in again."
    redirect_to root_url
  end
  
  # List of positions someone working at a house might have.  It has been put in the App Controller
  # because it needs to be accessed by both the House views and the HouseStaff controller.  So
  # to keep it consistent and not duplicate code, it is here where both have access to retrieving it.
  #
  # THE ORDER IN WHICH POSITIONS ARE IN THIS ARRAY IS THE ORDER IN WHICH THEY WILL BE SORTED
  # WHEN VIEWING THE STAFF OF A HOUSE.  IF THIS ORDER GETS CHANGED, THE VALUE IN HouseStaff.sort_order
  # WILL BE OFF AND WILL NEED TO BE ADJUSTED.  AN EXCEPTION IS IF A POSITION IS ADDED AT THE END.
  def house_position_list
    @house_position_list = ["Res. Dir. Clinical Manager", "Res. Dir. Nurse Case Manager", "Assistant House Director",
                          "House Coordinator", "House Manager", "Skills Instructor", "Awake Overnight", "Sleep Overnight",
                          "Relief Manager", "PSS"]
  end
  
end
