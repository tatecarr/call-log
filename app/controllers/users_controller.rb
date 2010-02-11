class UsersController < ApplicationController
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      session[:user_id] = @user.id
      flash[:notice] = "Thank you for signing up! You are now logged in."
      redirect_to root_url
    else
      render :action => 'new'
    end
  end
  
  def password_reset
    @user = User.new
  end
  
  # reset the current users password on request
  def reset_user_password
    
    # we need the user that's currently logged in
    @user = User.find_by_email(current_user.email)
    
    # update the password with the new one specified
    if @user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
    
      # send them an email to remind them of the new password
      UserMailer.deliver_forgotten_password(@user)
      flash[:notice] = "Your password has been reset. An email has been sent with your new login credentials"
    else
      # passwords don't match
      flash[:error] = "Please make sure your passwords match. We were unable to reset your password."
    end
    
    redirect_to :action => "password_reset"
  end
  
  def destroy
	  @user = User.find(params[:id])
    if current_user != @user
      @house.destroy
    else
      flash[:error] = "You cannot delete yourself!"
    end
    redirect_to :controller => "admin", :action => 'index'
	end
end
