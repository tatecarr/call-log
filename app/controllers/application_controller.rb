# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Authentication
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  helper_method :admin?
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  protected
  
  def admin?
    current_user.role == "System-Admin"
  end
end
