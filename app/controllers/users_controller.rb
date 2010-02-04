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
    if @user.update_attributes(:password => params[:user][:password])
    
      # send them an email to remind them of the new password
      UserMailer.deliver_forgotten_password(@user)
      flash[:notice] = "Your password has been reset."
    else
      # looks like we couldn't update for some reason...this shouldn't ever happen
      flash[:error] = "We were unable to reset your password."
    end
    
    redirect_to :action => 'index'
  end
end
