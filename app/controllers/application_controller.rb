# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Authentication
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  helper_method :admin?
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
end
