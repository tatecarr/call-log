class UsersController < ApplicationController
  before_filter :login_required
  
  def password_reset
    @user = User.new
  end
  
  # reset the current users password on request
  def reset_user_password
    
    # check to see if they didn't fill anything in
    if params[:user][:password].blank? || params[:user][:password_confirmation].blank?
      flash[:error] = "One or more of the fields were left blank. Please fill in both fields and try again."
      redirect_to :action => "password_reset" and return
    end
    
    # we need the user that's currently logged in
    @user = User.find_by_email(current_user.email)
    
    # update the password with the new one specified
    if @user.update_attributes(:system_generated_pw => false,
                                :password => params[:user][:password],
                                :password_confirmation => params[:user][:password_confirmation])
                                
      # send them an email to remind them of the new password
      UserMailer.deliver_forgotten_password(@user)
      flash[:notice] = "Your password has been reset. An email has been sent with your new login credentials"
      redirect_to :controller => "sessions", :action => "home"
    else
      # passwords don't match
      flash[:error] = "We were unable to reset your password. Please make sure your passwords match."
      redirect_to :action => "password_reset"
    end
  end
  
  def destroy
	  @user = User.find(params[:id])
    if current_user != @user
      @user.destroy
    else
      flash[:error] = "You cannot delete yourself!"
    end
    redirect_to :controller => "admin", :action => 'index'
	end
end
