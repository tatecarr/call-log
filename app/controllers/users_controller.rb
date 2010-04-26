class UsersController < ApplicationController
  
  # make sure they are logged in
  before_filter :login_required
  
  # the password reset page
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
  
  # remove a user from the database. This is called from the admin page so may be wise to move this to the admin controller...
  def destroy
	  @user = User.find(params[:id])
    
    # make sure they aren't trying to delete themselves. This is our way of ensuring at least one account always remains.
    if current_user != @user
      @user.destroy
    else
      flash[:error] = "You cannot delete yourself!"
    end
    redirect_to :controller => "admin", :action => 'index'
	end
end
